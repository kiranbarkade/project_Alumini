const Post = require('../models/Post');
const User = require('../models/User');

// @desc    Get all posts
// @route   GET /api/posts
// @access  Public
exports.getPosts = async (req, res, next) => {
  try {
    const posts = await Post.find()
      .populate('userId', 'name designation company role profileImage')
      .populate('comments.userId', 'name designation company role profileImage')
      .sort({ createdAt: -1 });

    res.status(200).json({ success: true, count: posts.length, data: posts });
  } catch (err) {
    next(err);
  }
};

// @desc    Create a new post
// @route   POST /api/posts
// @access  Public
exports.createPost = async (req, res, next) => {
  try {
    const post = await Post.create(req.body);
    const populatedPost = await Post.findById(post._id).populate('userId', 'name designation company role profileImage');
    res.status(201).json({ success: true, data: populatedPost });
  } catch (err) {
    next(err);
  }
};

// @desc    Like / Unlike a post
// @route   PUT /api/posts/:id/like
// @access  Public
exports.likePost = async (req, res, next) => {
  try {
    const { userId } = req.body;
    if (!userId) {
      return res.status(400).json({ success: false, error: 'User ID is required' });
    }

    const post = await Post.findById(req.params.id);
    if (!post) {
      return res.status(404).json({ success: false, error: 'Post not found' });
    }

    const index = post.likes.indexOf(userId);

    if (index === -1) {
      // Like
      post.likes.push(userId);
    } else {
      // Unlike
      post.likes.splice(index, 1);
    }

    await post.save();

    res.status(200).json({ success: true, data: post });
  } catch (err) {
    next(err);
  }
};

// @desc    Comment on a post
// @route   POST /api/posts/:id/comments
// @access  Public
exports.commentPost = async (req, res, next) => {
  try {
    const { userId, content } = req.body;
    if (!userId || !content) {
      return res.status(400).json({ success: false, error: 'User ID and comment content are required' });
    }

    const post = await Post.findById(req.params.id);
    if (!post) {
      return res.status(404).json({ success: false, error: 'Post not found' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }

    const comment = {
      userId,
      userName: user.name,
      userImage: user.profileImage,
      content,
      createdAt: new Date()
    };

    post.comments.push(comment);
    await post.save();

    const updatedPost = await Post.findById(req.params.id)
      .populate('userId', 'name designation company role profileImage')
      .populate('comments.userId', 'name designation company role profileImage');

    res.status(201).json({ success: true, data: updatedPost });
  } catch (err) {
    next(err);
  }
};
