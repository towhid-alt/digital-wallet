const express = require("express")
const { createAccountController } = require("../controllers/accountController.js")
const { authMiddleware } = require("../middleware/middlewareAuth.js")

const router = express.Router()

router.post("/create", authMiddleware, createAccountController)

module.exports= router