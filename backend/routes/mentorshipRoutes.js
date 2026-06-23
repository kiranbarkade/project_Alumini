const express = require('express');
const router = express.Router();
const {
  createMentorshipRequest,
  getMentorshipSessions,
  updateMentorshipStatus
} = require('../controllers/mentorshipController');

router.route('/')
  .post(createMentorshipRequest)
  .get(getMentorshipSessions);

router.route('/:id')
  .put(updateMentorshipStatus);

module.exports = router;
