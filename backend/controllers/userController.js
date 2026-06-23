const User = require('../models/User');
const Job = require('../models/Job');
const Referral = require('../models/Referral');
const Mentorship = require('../models/Mentorship');

// @desc    Get all users (with search and filters)
// @route   GET /api/users
// @access  Public
exports.getUsers = async (req, res, next) => {
  try {
    const { role, company, skills, search, graduationYear, page = 1, limit = 10 } = req.query;
    const query = {};

    if (role) query.role = role;
    if (graduationYear) query.graduationYear = Number(graduationYear);
    if (company) query.company = { $regex: company, $options: 'i' };
    if (skills) {
      const skillsArray = skills.split(',');
      query.skills = { $all: skillsArray };
    }
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { company: { $regex: search, $options: 'i' } },
        { skills: { $regex: search, $options: 'i' } }
      ];
    }

    const total = await User.countDocuments(query);
    const users = await User.find(query)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(Number(limit));

    res.status(200).json({
      success: true,
      count: users.length,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total
      },
      data: users
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get single user
// @route   GET /api/users/:id
// @access  Public
exports.getUser = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }
    res.status(200).json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
};

// @desc    Create user
// @route   POST /api/users
// @access  Public
exports.createUser = async (req, res, next) => {
  try {
    const user = await User.create(req.body);
    res.status(201).json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
};

// @desc    Update user profile
// @route   PUT /api/users/:id
// @access  Public
exports.updateUser = async (req, res, next) => {
  try {
    let user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }

    user = await User.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });

    res.status(200).json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
};

// @desc    Get Admin Stats
// @route   GET /api/users/stats/admin
// @access  Public
exports.getAdminStats = async (req, res, next) => {
  try {
    const totalUsers = await User.countDocuments();
    const totalAlumni = await User.countDocuments({ role: 'alumni' });
    const totalStudents = await User.countDocuments({ role: 'student' });
    const totalJobs = await Job.countDocuments();

    // Referral stats
    const totalReferrals = await Referral.countDocuments();
    const pendingReferrals = await Referral.countDocuments({ status: 'pending' });
    const acceptedReferrals = await Referral.countDocuments({ status: 'accepted' });
    const rejectedReferrals = await Referral.countDocuments({ status: 'rejected' });

    res.status(200).json({
      success: true,
      data: {
        totalUsers,
        totalAlumni,
        totalStudents,
        totalJobs,
        referrals: {
          total: totalReferrals,
          pending: pendingReferrals,
          accepted: acceptedReferrals,
          rejected: rejectedReferrals,
          acceptanceRate: totalReferrals > 0 ? ((acceptedReferrals / totalReferrals) * 100).toFixed(1) : 0
        }
      }
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get Alumni Stats
// @route   GET /api/users/stats/alumni/:id
// @access  Public
exports.getAlumniStats = async (req, res, next) => {
  try {
    const alumniId = req.params.id;

    const totalReferrals = await Referral.countDocuments({ alumniId });
    const pendingReferrals = await Referral.countDocuments({ alumniId, status: 'pending' });
    const acceptedReferrals = await Referral.countDocuments({ alumniId, status: 'accepted' });
    const jobsPosted = await Job.countDocuments({ postedBy: alumniId });
    const mentorshipRequests = await Mentorship.countDocuments({ alumniId, status: 'pending' });
    const activeMentorships = await Mentorship.countDocuments({ alumniId, status: 'approved' });

    res.status(200).json({
      success: true,
      data: {
        totalReferrals,
        pendingReferrals,
        acceptedReferrals,
        jobsPosted,
        mentorshipRequests,
        activeMentorships
      }
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Login user by email and password
// @route   POST /api/users/login
// @access  Public
exports.loginUser = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, error: 'Please add an email and password' });
    }

    // Include password field since select is false
    const user = await User.findOne({ email }).select('+password');
    if (!user || user.password !== password) {
      return res.status(401).json({ success: false, error: 'Invalid credentials.' });
    }

    // Remove password from output
    user.password = undefined;

    res.status(200).json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
};
