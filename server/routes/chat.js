// server/routes/chat.js
const express = require('express');
const router = express.Router();
const Message = require('../models/Message');
const User = require('../models/User');

// GET /chat/history/:partnerId?limit=20&before=timestamp
router.get('/history/:partnerId', async (req, res) => {
  const { partnerId } = req.params;
  const userId = req.user.id;
  const limit = parseInt(req.query.limit) || 20;
  const before = req.query.before ? new Date(req.query.before) : new Date();
  try {
    const messages = await Message.find({
      $or: [
        { senderId: userId, receiverId: partnerId },
        { senderId: partnerId, receiverId: userId }
      ],
      timestamp: { $lt: before }
    })
      .sort({ timestamp: -1 })
      .limit(limit)
      .populate('senderId', 'name profileImage')
      .populate('receiverId', 'name profileImage');
    res.json(messages);
  } catch (err) {
    console.error('History error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

// POST /chat/message  (fallback for offline send)
router.post('/message', async (req, res) => {
  const { receiverId, content, type = 'text' } = req.body;
  const senderId = req.user.id;
  try {
    const message = await Message.create({ senderId, receiverId, content, status: 'sent', type });
    res.status(201).json(message);
  } catch (err) {
    console.error('Create message error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

// PATCH /chat/message/:id/read  (mark as read)
router.patch('/message/:id/read', async (req, res) => {
  const { id } = req.params;
  try {
    const message = await Message.findByIdAndUpdate(id, { status: 'read', readAt: new Date() }, { new: true });
    if (!message) return res.status(404).json({ message: 'Message not found' });
    res.json(message);
  } catch (err) {
    console.error('Read receipt error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
