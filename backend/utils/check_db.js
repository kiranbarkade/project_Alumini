const dns = require('dns');
dns.setServers(['8.8.8.8', '8.8.4.4']);

const mongoose = require('mongoose');
const path = require('path');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../../.env') });

const User = require('../models/User');

const checkDb = async () => {
  try {
    const uri = process.env.MONGODB_URI;
    console.log('Connecting to:', uri ? uri.substring(0, 30) + '...' : 'undefined');
    
    await mongoose.connect(uri || 'mongodb://127.0.0.1:27017/careerbridge');
    console.log('MongoDB Connected successfully!');
    
    const users = await User.find({}).select('+password');
    console.log(`Found ${users.length} users in the database:`);
    users.forEach(u => {
      console.log(`- Name: ${u.name}, Email: ${u.email}, Password: ${u.password}, Role: ${u.role}`);
    });
    
    mongoose.connection.close();
  } catch (err) {
    console.error('Error connecting to database:', err);
  }
};

checkDb();
