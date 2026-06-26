// server/models/User.js
const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  role: { type: String, enum: ['student', 'alumni'], required: true },
  profileImage: { type: String, default: '' },
  onlineStatus: { type: Boolean, default: false },
  lastSeen: { type: Date, default: Date.now },
  socketId: { type: String, default: '' },
});

module.exports = mongoose.model('User', UserSchema);
