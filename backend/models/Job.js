const mongoose = require('mongoose');

const jobSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please add a job title'],
    trim: true
  },
  company: {
    type: String,
    required: [true, 'Please add a company name'],
    trim: true
  },
  location: {
    type: String,
    required: [true, 'Please add a location']
  },
  type: {
    type: String,
    enum: ['fulltime', 'internship', 'referral', 'event'],
    required: [true, 'Please specify the job type']
  },
  description: {
    type: String,
    required: [true, 'Please add a description']
  },
  postedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  skillsRequired: {
    type: [String],
    default: []
  },
  salary: {
    type: String,
    default: ''
  },
  experienceRequired: {
    type: String,
    default: 'Fresher'
  },
  deadline: {
    type: String,
    default: ''
  },
  applyLink: {
    type: String,
    default: ''
  },
  companyLogo: {
    type: String,
    default: ''
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Job', jobSchema);
