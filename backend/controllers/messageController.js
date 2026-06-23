const Message = require('../models/Message');
const User = require('../models/User');

// @desc    Send a message
// @route   POST /api/messages
// @access  Public
exports.sendMessage = async (req, res, next) => {
  try {
    const { senderId, receiverId, message } = req.body;

    if (!senderId || !receiverId || !message) {
      return res.status(400).json({ success: false, error: 'Sender, receiver, and message content are required' });
    }

    const newMessage = await Message.create({
      senderId,
      receiverId,
      message
    });

    res.status(201).json({ success: true, data: newMessage });
  } catch (err) {
    next(err);
  }
};

// @desc    Get chat history between two users
// @route   GET /api/messages/history/:userId/:otherUserId
// @access  Public
exports.getChatHistory = async (req, res, next) => {
  try {
    const { userId, otherUserId } = req.params;

    const messages = await Message.find({
      $or: [
        { senderId: userId, receiverId: otherUserId },
        { senderId: otherUserId, receiverId: userId }
      ]
    }).sort({ createdAt: 1 });

    res.status(200).json({ success: true, count: messages.length, data: messages });
  } catch (err) {
    next(err);
  }
};

// @desc    Get active conversations list for a user
// @route   GET /api/messages/conversations/:userId
// @access  Public
exports.getConversations = async (req, res, next) => {
  try {
    const { userId } = req.params;

    // Find all messages involving the user, sorted by newest first
    const messages = await Message.find({
      $or: [{ senderId: userId }, { receiverId: userId }]
    }).sort({ createdAt: -1 });

    const conversationMap = new Map();

    for (const msg of messages) {
      const otherUserId = msg.senderId.toString() === userId 
        ? msg.receiverId.toString() 
        : msg.senderId.toString();

      if (!conversationMap.has(otherUserId)) {
        conversationMap.set(otherUserId, msg);
      }
    }

    // Now populate user details for each other user
    const conversations = [];
    for (const [otherUserId, lastMsg] of conversationMap.entries()) {
      const otherUser = await User.findById(otherUserId).select('name role designation company profileImage branch graduationYear isVerified');
      if (otherUser) {
        conversations.push({
          otherUser,
          lastMessage: lastMsg.message,
          lastMessageTime: lastMsg.createdAt,
          senderId: lastMsg.senderId
        });
      }
    }

    res.status(200).json({ success: true, count: conversations.length, data: conversations });
  } catch (err) {
    next(err);
  }
};
