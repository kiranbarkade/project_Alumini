const express = require('express');
const router = express.Router();
const {
  getUsers,
  getUser,
  createUser,
  updateUser,
  getAdminStats,
  getAlumniStats,
  loginUser,
  uploadProfileImage
} = require('../controllers/userController');

router.route('/')
  .get(getUsers)
  .post(createUser);

router.route('/login')
  .post(loginUser);

router.route('/stats/admin')
  .get(getAdminStats);

router.route('/stats/alumni/:id')
  .get(getAlumniStats);

router.route('/:id/profile-image')
  .put(uploadProfileImage);

router.route('/:id')
  .get(getUser)
  .put(updateUser);

module.exports = router;
