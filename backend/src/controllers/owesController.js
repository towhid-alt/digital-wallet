const express = require('express')
const { db } = require('../prisma/db.ts')
const redis = require('../client.js')
const { fetchCacheKey } = require('./chatsController.js')

async function invalidateChatsCache(senderId, receiverId) {
    //Invalidating cache because of stale cache data
    try {
        const cacheKey = fetchCacheKey(senderId, receiverId)
        await redis.del(cacheKey)
    } catch (e) {
        console.error("Error invalidating cache: ", e)
    }
}

async function deleteOwe(req, res) {
    const data = req.body
    try {
        invalidateChatsCache(data.senderId, data.receiverId)
        const rejectedOwe = db.orm.public.Owes.where({ id: data.oweId })
            .update({ status: "REJECTED" })
        return res.status(200).json({ message: "Owe rejected" })
    } catch (e) {
        console.error("Error updating owe to REJECTED")
        return res.status(401).json({ message: "Error updating owe to REJ" })
    }
}

async function oweAccept(req, res) {
    const data = req.body

    try {
        invalidateChatsCache(data.senderId, data.receiverId)
        const acceptOwe = db.orm.public.Owes.where({ id: data.oweId })
            .update({ status: "ACCEPTED" })
        return res.status(200).json({ message: "Owe accepted" })
    } catch (e) {
        console.error("Error updating owe to Accepted")
        return res.status(401).json({ message: "Error updating owe to ACCEPTED" })
    }
}

module.exports = { deleteOwe, oweAccept }