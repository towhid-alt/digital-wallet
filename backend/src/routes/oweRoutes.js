const express = require('express')
const { deleteOwe, oweAccept } = require('../controllers/owesController')
const router = express.Router()

router.post('/delete', deleteOwe)
router.post('/accept', oweAccept)

module.exports = router