const express = require('express');
const router = express.Router();
const {
  createReferralRequest,
  getReferralRequests,
  updateReferralStatus
} = require('../controllers/referralController');

router.route('/')
  .post(createReferralRequest)
  .get(getReferralRequests);

router.route('/:id')
  .put(updateReferralStatus);

module.exports = router;
