const jwt = require('jsonwebtoken');

module.exports = async (req, res, next) => {
    const token = req.header('Authorization');
    if (!token) return res.status(401).send('Access Denied');
    //Check session expiry
    try {
        const verified = jwt.verify(token, process.env.TOKEN_SECRET);
        const currentTime = Math.floor(Date.now() / 1000);
        if (verified.exp < currentTime) {
            return res.status(401).send('Token has expired');
        }
        req.user = verified;
        next();
    } catch (ex) {
        res.status(400).send('Invalid Token');
    }
};  