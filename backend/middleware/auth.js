const jwt = require('jsonwebtoken');

module.exports = async (req, res, next) => {
  const authHeader = req.header('Authorization');
  if (!authHeader) {
    return res.status(401).send('Access Denied: No Authorization header provided');
  }
  const token = authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).send('Access Denied: No token provided');
  }
  try {
    const secretKey = "varun";
    const verified = jwt.verify(token, secretKey); 
    req.user = verified;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).send('Token has expired');
    }
    res.status(400).send('Invalid Token');
  }
};
