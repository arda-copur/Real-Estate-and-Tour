const User = require('../models/User');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const path = require('path');

/**
 * Get user profile
 * @route GET /api/users/profile
 * @access Private
 */
exports.getUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    
    if (!user) {
      return res.status(404).json({ message: 'Kullanıcı bulunamadı' });
    }

    res.json(user);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Update user profile
 * @route PUT /api/users/profile
 * @access Private
 */
exports.updateUserProfile = async (req, res) => {
  try {
    const { firstName, lastName, phone, age, city, bio } = req.body;
    
    const updateData = {};
    if (firstName) updateData.firstName = firstName;
    if (lastName) updateData.lastName = lastName;
    if (phone) updateData.phone = phone;
    if (age) updateData.age = age;
    if (city) updateData.city = city;
    if (bio) updateData.bio = bio;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $set: updateData },
      { new: true, runValidators: true }
    ).select('-password');

    res.json({ user, message: 'Profil başarıyla güncellendi' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Upload profile image
 * @route POST /api/users/profile/image
 * @access Private
 */
exports.uploadProfileImage = async (req, res) => {
  try {
    console.log('Upload request received');
    console.log('Request file:', req.file);
    console.log('Request body:', req.body);

    if (!req.file) {
      return res.status(400).json({ message: 'Lütfen bir resim yükleyin' });
    }

    // Get old profile image to delete it (if not default)
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.status(404).json({ message: 'Kullanıcı bulunamadı' });
    }
    
    const oldImage = user.profileImage;
    console.log('Old image path:', oldImage);

    // Update user with new profile image
    const imagePath = req.file.path.replace(/\\/g, '/');
    console.log('New image path:', imagePath);

    // MongoDB'de kullanıcıyı güncelle
    const updatedUser = await User.findByIdAndUpdate(
      req.user.id,
      { 
        $set: { 
          profileImage: imagePath 
        } 
      },
      { 
        new: true,
        runValidators: true 
      }
    ).select('-password');

    console.log('Updated user:', JSON.stringify(updatedUser, null, 2));

    // Delete old image if not default and exists
    if (oldImage && 
        !oldImage.includes('default-profile.jpg') && 
        fs.existsSync(oldImage)) {
      try {
        fs.unlinkSync(oldImage);
        console.log('Old image deleted successfully');
      } catch (error) {
        console.error('Error deleting old image:', error);
      }
    }

    res.json({ 
      user: updatedUser,
      message: 'Profil resmi başarıyla güncellendi' 
    });
  } catch (error) {
    console.error('Upload profile image error:', error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Change password
 * @route PUT /api/users/change-password
 * @access Private
 */
exports.changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    // Validate request
    if (!currentPassword || !newPassword) {
      return res.status(400).json({ message: 'Tüm alanları doldurmanız gerekiyor' });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({ message: 'Şifre en az 6 karakter olmalıdır' });
    }

    // Get user with password
    const user = await User.findById(req.user.id).select('+password');
    
    // Check current password
    const isMatch = await user.comparePassword(currentPassword);
    if (!isMatch) {
      return res.status(401).json({ message: 'Mevcut şifre yanlış' });
    }

    // Update password
    user.password = newPassword;
    await user.save();

    res.json({ message: 'Şifre başarıyla değiştirildi' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Get public user profile
 * @route GET /api/users/public/:userId
 * @access Public
 */
exports.getPublicUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.params.userId).select(
      'firstName lastName username role profileImage createdAt updatedAt age city bio'
    );
    
    if (!user) {
      return res.status(404).json({ message: 'Kullanıcı bulunamadı' });
    }

    res.json(user);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Get user by ID (for admins or hosts viewing guests)
 * @route GET /api/users/:userId
 * @access Private (Admin or resource owner)
 */
exports.getUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.userId).select('-password');
    
    if (!user) {
      return res.status(404).json({ message: 'Kullanıcı bulunamadı' });
    }

    res.json(user);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Update user role (admin only)
 * @route PUT /api/users/:userId/role
 * @access Private (Admin)
 */
exports.updateUserRole = async (req, res) => {
  try {
    const { role } = req.body;
    
    if (!role || !['user', 'host', 'admin'].includes(role)) {
      return res.status(400).json({ message: 'Geçerli bir rol belirtilmedi' });
    }

    const user = await User.findByIdAndUpdate(
      req.params.userId,
      { $set: { role } },
      { new: true, runValidators: true }
    ).select('-password');
    
    if (!user) {
      return res.status(404).json({ message: 'Kullanıcı bulunamadı' });
    }

    res.json({ user, message: `Kullanıcı rolü ${role} olarak güncellendi` });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Get saved properties
 * @route GET /api/users/saved/properties
 * @access Private
 */
exports.getSavedProperties = async (req, res) => {
  try {
    const user = await User.findById(req.user.id)
      .populate('savedProperties')
      .select('savedProperties');
    
    res.json(user.savedProperties);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Save property to favorites
 * @route POST /api/users/saved/properties/:propertyId
 * @access Private
 */
exports.saveProperty = async (req, res) => {
  try {
    const propertyId = req.params.propertyId;
    
    // Check if property already saved
    const user = await User.findById(req.user.id);
    if (user.savedProperties.includes(propertyId)) {
      return res.status(400).json({ message: 'Bu ev zaten favorilerinizde' });
    }
    
    // Add property to saved list
    await User.findByIdAndUpdate(
      req.user.id,
      { $push: { savedProperties: propertyId } }
    );
    
    res.json({ message: 'Ev favorilerinize eklendi' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Remove property from favorites
 * @route DELETE /api/users/saved/properties/:propertyId
 * @access Private
 */
exports.removeSavedProperty = async (req, res) => {
  try {
    await User.findByIdAndUpdate(
      req.user.id,
      { $pull: { savedProperties: req.params.propertyId } }
    );
    
    res.json({ message: 'Ev favorilerinizden kaldırıldı' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Get saved experiences
 * @route GET /api/users/saved/experiences
 * @access Private
 */
exports.getSavedExperiences = async (req, res) => {
  try {
    const user = await User.findById(req.user.id)
      .populate('savedExperiences')
      .select('savedExperiences');
    
    res.json(user.savedExperiences);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Save experience to favorites
 * @route POST /api/users/saved/experiences/:experienceId
 * @access Private
 */
exports.saveExperience = async (req, res) => {
  try {
    const experienceId = req.params.experienceId;
    
    // Check if experience already saved
    const user = await User.findById(req.user.id);
    if (user.savedExperiences.includes(experienceId)) {
      return res.status(400).json({ message: 'Bu deneyim zaten favorilerinizde' });
    }
    
    // Add experience to saved list
    await User.findByIdAndUpdate(
      req.user.id,
      { $push: { savedExperiences: experienceId } }
    );
    
    res.json({ message: 'Deneyim favorilerinize eklendi' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Remove experience from favorites
 * @route DELETE /api/users/saved/experiences/:experienceId
 * @access Private
 */
exports.removeSavedExperience = async (req, res) => {
  try {
    await User.findByIdAndUpdate(
      req.user.id,
      { $pull: { savedExperiences: req.params.experienceId } }
    );
    
    res.json({ message: 'Deneyim favorilerinizden kaldırıldı' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
}; 