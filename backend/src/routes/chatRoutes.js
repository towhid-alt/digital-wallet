const express = require("express")
const app = require("../../server")
const { authMiddleware } = require("../middleware/middlewareAuth")
const { fetchChats, sendChat } = require("../controllers/chatsController")

const router = express.Router()

router.get('/fetchChats', authMiddleware, fetchChats)
router.post('/send', authMiddleware, sendChat)

module.exports = router