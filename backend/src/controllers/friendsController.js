const express = require('express')
const { db } = require('../prisma/db.ts')
const { and } = require("@prisma/orm-postgres/orm-client")

/**
 * Send Friend Request Controller function
 */
async function sendRequestController(req, res) {
    const user = req.user
    const { receiverName } = req.body
    try {

        const userExists = await db.orm.public.User.where((p) => p.username.ilike(receiverName)).first()
        if (userExists) {
            await db.orm.public.FriendRequest.create({
                senderId: user.id,
                receiverId: userExists.id,
                updatedAt: new Date()
            })
            console.log('Friend Request addedd to DB successfully')
            return res.status(200).json({ message: "Request Sent successfully" })
        } else {
            return res.status(400).json({ message: "User not found" })
        }
    } catch (e) {
        console.error('Error sending friend request:', e)
        return res.status(500).json({ message: "Internal Server error" })
    }
}

/**
 * Fetch Friend Requests
 */
async function fetchRequests(req, res) {
    const user = req.user
    try{
        console.log("Inside fetchRequests controller...")
        const requestList = await db.orm.public.FriendRequest.where((p) => and(p.receiverId.eq(user.id),p.status.eq('PENDING')))
        .include("sender",(sender) => sender.select("username"))
        .all()
        if(requestList)
        {
            const senderNames = requestList.map((request) => request.sender.username)
            console.log("Friend request API returns -> ",senderNames)
            return res.status(200).json({requests: senderNames})}
        else {
            return res.status(500).json({message:"No pending request found"})
        }
    } catch(e){
        console.log('Error: ',e)
        return res.status(400).json({message: "Internal server error"})
    }
}

module.exports = { sendRequestController, fetchRequests }