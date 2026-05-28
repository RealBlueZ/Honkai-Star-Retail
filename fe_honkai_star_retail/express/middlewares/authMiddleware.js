const jwt = require('jsonwebtoken');
const db = require('../config/db');

const verifyToken = async (req, res, next) => {
    const authHeader = req.headers['authorization'];
    
    // Memastikan format "Bearer <token>"
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ message: 'Access Denied. No token provided.' });
    }

    const token = authHeader.split(' ')[1];

    try {
        // 1. Verifikasi validitas JWT secara kriptografi
        const verified = jwt.verify(token, process.env.JWT_SECRET);
        
        // 2. Verifikasi tambahan: cek apakah token masih aktif di tabel auth_tokens
        const [rows] = await db.execute(
            'SELECT * FROM auth_tokens WHERE token = ? AND expires_at > NOW()', 
            [token]
        );

        if (rows.length === 0) {
            return res.status(401).json({ message: 'Token is invalid or has expired.' });
        }

        // Menyimpan data user terverifikasi ke dalam object request
        req.user = verified; 
        next();
    } catch (error) {
        return res.status(403).json({ message: 'Invalid or Expired Token.' });
    }
};

module.exports = verifyToken;