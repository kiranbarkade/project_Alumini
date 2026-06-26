// server/sockets/chatSocket.js
module.exports = (io, socket) => {
  const userId = socket.userId; // attached in auth middleware

  // Mark user online (already done in connection handler of app.js, but ensure socketId stored)
  const User = require('../models/User');
  User.findByIdAndUpdate(userId, { onlineStatus: true, socketId: socket.id })
    .catch(err => console.error('Error setting online status:', err));

  // Join private room for direct messages
  socket.join(userId);

  // Typing indicator
  socket.on('typing', ({ to }) => {
    socket.to(to).emit('typing', { from: userId });
  });

  // Send message
  socket.on('message', async ({ to, content }) => {
    const Message = require('../models/Message');
    try {
      const msg = await Message.create({
        senderId: userId,
        receiverId: to,
        content,
        status: 'sent'
      });
      // Emit to sender (sent) and receiver (delivered)
      socket.emit('message:sent', msg);
      socket.to(to).emit('message:delivered', msg);
    } catch (err) {
      console.error('Socket message error:', err);
    }
  });

  // Read receipt
  socket.on('message:read', async ({ messageId }) => {
    const Message = require('../models/Message');
    try {
      const msg = await Message.findByIdAndUpdate(
        messageId,
        { status: 'read', readAt: new Date() },
        { new: true }
      );
      if (!msg) return;
      // Notify both parties
      io.to(msg.senderId.toString()).emit('message:read', msg);
      io.to(msg.receiverId.toString()).emit('message:read', msg);
    } catch (err) {
      console.error('Read receipt socket error:', err);
    }
  });

  // Handle disconnect
  socket.on('disconnect', async () => {
    try {
      await User.findByIdAndUpdate(userId, { onlineStatus: false, lastSeen: new Date(), socketId: null });
    } catch (err) {
      console.error('Disconnect update error:', err);
    }
  });
};
