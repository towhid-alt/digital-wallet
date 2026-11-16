const express = require('express')
const { db } = require('../prisma/db.ts')
const { authMiddleware } = require('../middleware/middlewareAuth.js')
const { sendRequestController, fetchRequests } = require('../controllers/friendsController.js')

const router = express.Router()

router.post('/send', authMiddleware, sendRequestController)
router.post('/fetch', authMiddleware, fetchRequests)

module.exports= router;