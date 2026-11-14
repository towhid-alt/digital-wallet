const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { db } = require('../prisma/db.ts');
const { and, not, or } = require("@prisma/orm-postgres/orm-client")
const http = require('http');


const router = express.Router();

router.post('/register', async (req, res) => {
    const {email, password, username} = req.body;
    try {
        console.log("Register request received:", { email, username });
        const hashedPassword = await bcrypt.hash(password, 8);
        const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/
        if (!emailRegex.test(email)) {
            return res.status(400).json({ message: "Invalid email format" })
        }
        
        if (password.length < 6) {
            return res.status(400).json({ message: "Password should be atleast 6 characters long" })
        }
        console.log("Password hashed successfully for user: ", username)
        const userExists = await db.orm.public.User.where((p) => or(p.email.ilike(email), p.username.ilike(username))).first()
        if (userExists) {
            return res.status(400).json({ message: "User already exists" })
        }
        console.log("Creating user:", { email, username });
        const user = await db.orm.public.User.create({
            email: email,
            username: username,
            password: hashedPassword
        })
        //Create a JWT token for the user
        const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' })
        console.log("Token created")
        res.cookie("token", token)
        //Creating default account during registration
        const account = db.orm.public.Account.create({
            userId: user.id
        })
        res.status(200).json({ message: "User created successfully", userId: user.id })
    } catch (e) {
        console.error("Error creating user:", error)
        res.status(500).json({ message: "Internal server error" })
    }
})

router.post('/login', async (req, res) => {
    const {email, password} = req.body;
    try{ 
        console.log("Login request received:", { email, password });
        const user = await db.orm.public.User.where((p) => p.email.ilike(email)).first()
        if (!user) {
            return res.status(400).json({ message: "Invalid email or password" })
        }
        const comparePw = await bcrypt.compare(password, user.password)
        if (!comparePw) {
            return res.status(400).json({ message: "Invalid email or password" })
        }
        //Create a JWT token for the user
        const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' })
        res.cookie("token", token)
        res.status(200).json({ message: "Login successful", userId: user.id })
    } catch (error) {
        console.error("Error during login:", error)
        res.status(500).json({ message: "Internal server error" })
    }
})
module.exports = router;