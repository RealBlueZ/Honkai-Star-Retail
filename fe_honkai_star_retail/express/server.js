const express = require('express');
const passport = require('passport');
const path = require('path');
const dotenv = require('dotenv');
const authController = require('./controllers/authController');
const resourceController = require('./controllers/resourceController');

dotenv.config();

const app = express();

// Middleware parsing JSON body requests
app.use(express.json());
app.use(passport.initialize());

// Daftarkan rute autentikasi
app.use('/api/auth', authController);
app.use('/uploads', express.static(path.join(__dirname, 'public/images'))); // Menyajikan file gambar yang diupload
app.use('/api', resourceController);
app.use('/images', express.static(path.join(__dirname, 'public/images')));

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT}`);
});