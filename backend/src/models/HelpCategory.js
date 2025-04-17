const mongoose = require('mongoose');

const helpCategorySchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Category title is required'],
      trim: true,
      unique: true,
    },
    icon: {
      type: String,
      required: [true, 'Icon is required'],
    },
    description: {
      type: String,
      trim: true,
    },
    articles: [{
      title: {
        type: String,
        required: true,
        trim: true,
      },
      content: {
        type: String,
        required: true,
      },
      isPopular: {
        type: Boolean,
        default: false,
      },
    }],
    order: {
      type: Number,
      default: 0,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// Index for search
helpCategorySchema.index({ title: 'text', 'articles.title': 'text', 'articles.content': 'text' });

const HelpCategory = mongoose.model('HelpCategory', helpCategorySchema);

module.exports = HelpCategory; 