const express = require('express');
const passport = require('passport');
const authRouter = require('./authRouter');
const verifyToken = require('./authMiddleware');

const app = express();

// Middleware parsing JSON body requests
app.use(express.json());
app.use(passport.initialize());

// Daftarkan rute autentikasi
app.use('/api/auth', authRouter);


// Menggunakan middleware 'verifyToken' untuk memverifikasi bearer token 
app.post('/api/resources', verifyToken, (req, res) => {
    // Memeriksa role dari token yang didekripsi oleh middleware
    if (req.user.role !== 'admin') {
        return res.status(430).json({ message: 'Forbidden. Admin role required.' });
    }
    
    // Logika Insert Item Honkai Star Retail ke Database ada di sini
    res.json({ message: "Item added successfully by Admin!", adminId: req.user.id });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});