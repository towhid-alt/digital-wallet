const express = require('express')
const { db } = require('../prisma/db.ts')
const { authMiddleware } = require('../middleware/middlewareAuth.js')
const { sendRequestController, fetchRequests, requestAccepted, requestRejected, fetchFriends } = require('../controllers/friendsController.js')

const router = express.Router()

router.post('/send', authMiddleware, sendRequestController)
router.post('/fetch', authMiddleware, fetchRequests)
router.put('/accept', authMiddleware, requestAccepted)
router.put('/reject', authMiddleware, requestRejected)
router.put('/fetchFriends', authMiddleware, fetchFriends)

module.exports= router;