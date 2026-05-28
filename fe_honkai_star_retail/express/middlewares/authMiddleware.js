const jwt = require('jsonwebtoken');
const db = require('../config/db');

const verifyToken = async (req, res, next) => {
    const authHeader = req.headers['authorization'];
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ message: 'Access Denied. No token provided.' });
    }

    const token = authHeader.split(' ')[1];

    try {

        const tokenParts = token.split('.');
        let jwtToken = token;
        
        if (tokenParts.length > 3) {
            jwtToken = `${tokenParts[0]}.${tokenParts[1]}.${tokenParts[2]}`;
        }


        const verified = jwt.verify(jwtToken, process.env.JWT_SECRET);
        

        const [rows] = await db.execute(
            'SELECT * FROM auth_tokens WHERE token = ? AND expires_at > NOW()', 
            [token]
        );

        if (rows.length === 0) {
            return res.status(401).json({ message: 'Token is invalid or has expired.' });
        }

  
        req.user = verified; 
        next();
    } catch (error) {
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