const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configure multer storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    console.log('Processing file upload:', file);
    let uploadPath = '';
    // Determine upload path based on file type
    if (file.fieldname === 'profileImage') {
      uploadPath = 'uploads/profiles';
    } else if (file.fieldname === 'propertyImages' || file.fieldname === 'propertyImage') {
      uploadPath = 'uploads/properties';
    } else if (file.fieldname === 'experienceImage') {
      uploadPath = 'uploads/experiences';
    } else if (file.fieldname === 'destinationImage') {
      uploadPath = 'uploads/destinations';
    } else {
      uploadPath = 'uploads/others';
    }

    // Create directory if it doesn't exist
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }

    console.log('Upload path:', uploadPath);
    cb(null, uploadPath);
  },
  filename: function (req, file, cb) {
    console.log('Original filename:', file.originalname);
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const extension = path.extname(file.originalname).toLowerCase();
    const filename = file.fieldname + '-' + uniqueSuffix + extension;
    console.log('Generated filename:', filename);
    cb(null, filename);
  }
});

// File filter to allow only images
const fileFilter = (req, file, cb) => {
  console.log('File filter called');
  console.log('File details:', {
    fieldname: file.fieldname,
    originalname: file.originalname,
    encoding: file.encoding,
    mimetype: file.mimetype,
  });
  
  // Herhangi bir "image/" ile başlayan MIME tipini kabul et
  if (file.mimetype.startsWith('image/') || 
      // MIME tipi düzgün belirlenmemişse dosya uzantısına bak
      ['jpg', 'jpeg', 'png', 'gif'].includes(
        path.extname(file.originalname).toLowerCase().substring(1)
      )) {
    console.log('File accepted - valid image');
    cb(null, true);
  } else {
    console.log('File rejected - not a valid image');
    cb(new Error('Geçersiz dosya formatı. Lütfen sadece JPG, PNG veya GIF formatında resim yükleyin.'), false);
  }
};

// Create multer upload instance
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  }
});

// Middleware for profile image upload
exports.uploadProfileImage = upload.single('profileImage');

// Middleware for property images upload (multiple)
exports.uploadPropertyImages = upload.array('propertyImages', 10);

// Middleware for single property image
exports.uploadPropertyImage = upload.single('propertyImage');

// Middleware for experience image
exports.uploadExperienceImage = upload.single('experienceImage');

// Middleware for destination image
exports.uploadDestinationImage = upload.single('destinationImage');

// Error handler for multer
exports.handleMulterError = (err, req, res, next) => {
  console.error('Multer error:', err);
  
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ message: 'Dosya boyutu çok büyük. Maksimum boyut 5MB olmalıdır.' });
    }
    return res.status(400).json({ message: `Yükleme hatası: ${err.message}` });
  } else if (err) {
    return res.status(400).json({ message: err.message });
  }
  next();
}; 