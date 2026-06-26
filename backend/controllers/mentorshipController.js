const Mentorship = require('../models/Mentorship');
const Notification = require('../models/Notification');
const User = require('../models/User');

// @desc    Create a mentorship request
// @route   POST /api/mentorships
// @access  Public
exports.createMentorshipRequest = async (req, res, next) => {
  try {
    const { studentId, alumniId, topic, date, timeSlot, status = 'pending', notes = '' } = req.body;

    const mentorship = await Mentorship.create({
      studentId,
      alumniId,
      topic,
      date,
      timeSlot,
      status,
      notes
    });

    const student = await User.findById(studentId);
    const alumni = await User.findById(alumniId);

    if (status === 'approved') {
      // Notify Student that the Alumni has connected
      await Notification.create({
        recipient: studentId,
        sender: alumniId,
        type: 'mentorship',
        message: `${alumni.name} connected with you!`,
        referenceId: mentorship._id.toString()
      });
    } else {
      // Notify Alumni about mentorship request
      await Notification.create({
        recipient: alumniId,
        sender: studentId,
        type: 'mentorship',
        message: `${student.name} requested a mentorship session: "${topic}"`,
        referenceId: mentorship._id.toString()
      });
    }

    res.status(201).json({ success: true, data: mentorship });
  } catch (err) {
    next(err);
  }
};

// @desc    Get mentorship sessions/requests for user (filters: studentId, alumniId)
// @route   GET /api/mentorships
// @access  Public
exports.getMentorshipSessions = async (req, res, next) => {
  try {
    const { studentId, alumniId } = req.query;
    const query = {};

    if (studentId) query.studentId = studentId;
    if (alumniId) query.alumniId = alumniId;

    const sessions = await Mentorship.find(query)
      .populate('studentId', 'name branch graduationYear skills profileImage email')
      .populate('alumniId', 'name designation company profileImage company about linkedinUrl')
      .sort({ date: 1 });

    res.status(200).json({ success: true, count: sessions.length, data: sessions });
  } catch (err) {
    next(err);
  }
};

// @desc    Update mentorship session status (approve, reject, complete)
// @route   PUT /api/mentorships/:id
// @access  Public
exports.updateMentorshipStatus = async (req, res, next) => {
  try {
    const { status, notes } = req.body;
    if (!['approved', 'rejected', 'completed'].includes(status)) {
      return res.status(400).json({ success: false, error: 'Invalid mentorship status update' });
    }

    let mentorship = await Mentorship.findById(req.params.id);
    if (!mentorship) {
      return res.status(404).json({ success: false, error: 'Mentorship session not found' });
    }

    const updates = { status };
    if (notes) updates.notes = notes;

    mentorship = await Mentorship.findByIdAndUpdate(
      req.params.id,
      updates,
      { new: true, runValidators: true }
    );

    const alumni = await User.findById(mentorship.alumniId);

    // Notify student about mentorship request update
    await Notification.create({
      recipient: mentorship.studentId,
      sender: mentorship.alumniId,
      type: 'mentorship',
      message: `Your mentorship request on "${mentorship.topic}" has been ${status} by ${alumni.name}`,
      referenceId: mentorship._id.toString()
    });

    res.status(200).json({ success: true, data: mentorship });
  } catch (err) {
    next(err);
  }
};
