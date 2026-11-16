const jwt = require("jsonwebtoken")
const { db } = require("../prisma/db.ts")

async function authMiddleware(req, res, next) {
    const token = req.cookies?.token || req.headers.authorization?.match(/^Bearer\s+(.+)$/i)?.[1]
    if (!token) {//TODO:Understand the regex for token
        return res.status(401).json({ message: "Empty token" })
    }

    let decoded
    try {
        decoded = jwt.verify(token, process.env.JWT_SECRET)
    } catch (error) {
        return res.status(401).json({ message: "Unauthorized or invalid token" })
    }

    const user = await db.orm.public.User.where((p) => p.id.eq(decoded.id)).first()
    if (!user) {
        return res.status(401).json({ message: "Unauthorized or invalid token" })
    }

    req.user = user
    return next()
}

module.exports = {authMiddleware}