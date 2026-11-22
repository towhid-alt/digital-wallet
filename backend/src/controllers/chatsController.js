const express = require("express")
const { db } = require("../prisma/db.ts")
const { and, or } = require("@prisma/orm-postgres/orm-client")
/**
 * Fetch chats
 */
async function fetchChats(req, res) {
    const currentUserId = req.query.currentUserId
    const receiverId = req.query.receiverId

    try {
        const chats = await db.orm.public.Owes.where((p) => or(
            and(p.senderId.eq(currentUserId), p.receiverId.eq(receiverId)),
            and(p.senderId.eq(receiverId), p.receiverId.eq(currentUserId)))).all()
        //console.log('Result of DB call: ',chats)
         if(chats){
            return res.status(200).json(chats)
         }else {
            return res.status(302).json({message: 'No chat found'})
         }
    } catch(e) {
        return res.status(400).json({message: "Internal server error"})
    }
}

/**
 * Send chat
 */
async function sendChat(req, res) {

}

module.exports = { fetchChats, sendChat }