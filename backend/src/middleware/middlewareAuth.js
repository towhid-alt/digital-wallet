const express = require("express")

async function authMiddleware(req, res, next) {
    const token = req.cookies.token || req.headers.authorization.split(' ')[1]
    try{
        if(!token){
        return res.status(401).json({message: "Empty token"})
    }
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET)
    const user = db.orm.public.User.where((p) => p.id.eq(decoded.id))

    req.user=user
    next()
    } catch(e){
        return res.status(400).json({message:"Unauthorized or invalid token"})
    }
    
}

module.exports = {authMiddleware}