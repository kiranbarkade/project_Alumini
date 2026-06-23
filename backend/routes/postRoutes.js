const express = require('express');
const router = express.Router();
const {
  getPosts,
  createPost,
  likePost,
  commentPost
} = require('../controllers/postController');

router.route('/')
  .get(getPosts)
  .post(createPost);

router.route('/:id/like')
  .put(likePost);

router.route('/:id/comments')
  .post(commentPost);

module.exports = router;
