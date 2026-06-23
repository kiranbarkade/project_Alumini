const Job = require('../models/Job');

// @desc    Get all jobs (with filters, search, pagination)
// @route   GET /api/jobs
// @access  Public
exports.getJobs = async (req, res, next) => {
  try {
    const { company, location, type, search, page = 1, limit = 10 } = req.query;
    const query = {};

    if (company) query.company = { $regex: company, $options: 'i' };
    if (location) query.location = { $regex: location, $options: 'i' };
    if (type) query.type = type;
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { company: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } }
      ];
    }

    const total = await Job.countDocuments(query);
    const jobs = await Job.find(query)
      .populate('postedBy', 'name designation company profileImage')
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(Number(limit));

    res.status(200).json({
      success: true,
      count: jobs.length,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total
      },
      data: jobs
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get single job details
// @route   GET /api/jobs/:id
// @access  Public
exports.getJob = async (req, res, next) => {
  try {
    const job = await Job.findById(req.params.id).populate('postedBy', 'name designation company profileImage email linkedinUrl');
    if (!job) {
      return res.status(404).json({ success: false, error: 'Job not found' });
    }
    res.status(200).json({ success: true, data: job });
  } catch (err) {
    next(err);
  }
};

// @desc    Create new job post
// @route   POST /api/jobs
// @access  Public
exports.createJob = async (req, res, next) => {
  try {
    const job = await Job.create(req.body);
    const populatedJob = await Job.findById(job._id).populate('postedBy', 'name designation company profileImage');
    res.status(201).json({ success: true, data: populatedJob });
  } catch (err) {
    next(err);
  }
};

// @desc    Update job post
// @route   PUT /api/jobs/:id
// @access  Public
exports.updateJob = async (req, res, next) => {
  try {
    let job = await Job.findById(req.params.id);
    if (!job) {
      return res.status(404).json({ success: false, error: 'Job not found' });
    }
    job = await Job.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });
    res.status(200).json({ success: true, data: job });
  } catch (err) {
    next(err);
  }
};

// @desc    Delete job post
// @route   DELETE /api/jobs/:id
// @access  Public
exports.deleteJob = async (req, res, next) => {
  try {
    const job = await Job.findById(req.params.id);
    if (!job) {
      return res.status(404).json({ success: false, error: 'Job not found' });
    }
    await job.deleteOne();
    res.status(200).json({ success: true, data: {} });
  } catch (err) {
    next(err);
  }
};
