const Referral = require('../models/Referral');
const Notification = require('../models/Notification');
const Job = require('../models/Job');
const User = require('../models/User');

// @desc    Create a referral request
// @route   POST /api/referrals
// @access  Public
exports.createReferralRequest = async (req, res, next) => {
  try {
    const { studentId, alumniId, jobId, message, companyName, jobTitle } = req.body;

    if (jobId) {
      const existingReferral = await Referral.findOne({ studentId, jobId });
      if (existingReferral) {
        return res.status(400).json({ success: false, error: 'You have already requested a referral for this job' });
      }
    }

    const referral = await Referral.create({
      studentId,
      alumniId,
      jobId,
      companyName,
      jobTitle,
      message
    });

    const student = await User.findById(studentId);
    const job = jobId ? await Job.findById(jobId) : null;

    const finalCompany = job ? job.company : (companyName || 'your company');
    const finalJobTitle = job ? job.title : (jobTitle || 'Referral');

    await Notification.create({
      recipient: alumniId,
      sender: studentId,
      type: 'referral',
      message: `${student.name} requested a referral for the position of "${finalJobTitle}" at "${finalCompany}"`,
      referenceId: referral._id.toString()
    });

    res.status(201).json({ success: true, data: referral });
  } catch (err) {
    next(err);
  }
};

// @desc    Get referral requests for a user (filters: studentId, alumniId)
// @route   GET /api/referrals
// @access  Public
exports.getReferralRequests = async (req, res, next) => {
  try {
    const { studentId, alumniId } = req.query;
    const query = {};

    if (studentId) query.studentId = studentId;
    if (alumniId) query.alumniId = alumniId;

    const referrals = await Referral.find(query)
      .populate('studentId', 'name email branch graduationYear skills resumeUrl profileImage')
      .populate('alumniId', 'name designation company profileImage')
      .populate('jobId', 'title company location type')
      .sort({ createdAt: -1 });

    res.status(200).json({ success: true, count: referrals.length, data: referrals });
  } catch (err) {
    next(err);
  }
};

// @desc    Update referral request status (Accept / Reject)
// @route   PUT /api/referrals/:id
// @access  Public
exports.updateReferralStatus = async (req, res, next) => {
  try {
    const { status } = req.body; // 'accepted' or 'rejected'
    if (!['accepted', 'rejected'].includes(status)) {
      return res.status(400).json({ success: false, error: 'Invalid status update. Must be accepted or rejected.' });
    }

    let referral = await Referral.findById(req.params.id);
    if (!referral) {
      return res.status(404).json({ success: false, error: 'Referral request not found' });
    }

    referral = await Referral.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true, runValidators: true }
    );

    // Fetch details for notification
    const alumni = await User.findById(referral.alumniId);
    const job = await Job.findById(referral.jobId);

    // Notify student about referral acceptance or rejection
    await Notification.create({
      recipient: referral.studentId,
      sender: referral.alumniId,
      type: 'referral',
      message: `Your referral request for "${job.title}" at "${job.company}" has been ${status} by ${alumni.name}`,
      referenceId: referral._id.toString()
    });

    res.status(200).json({ success: true, data: referral });
  } catch (err) {
    next(err);
  }
};
