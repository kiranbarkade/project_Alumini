const express = require('express');
const router = express.Router();
const {
  sendMessage,
  getChatHistory,
  getConversations
} = require('../controllers/messageController');

router.route('/')
  .post(sendMessage);

router.route('/history/:userId/:otherUserId')
  .get(getChatHistory);

router.route('/conversations/:userId')
  .get(getConversations);

module.exports = router;
