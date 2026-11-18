const express = require('express')
const { db } = require('../prisma/db.ts')
const { and, or } = require("@prisma/orm-postgres/orm-client")

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
    try {
        console.log("Inside fetchRequests controller...")
        const requestList = await db.orm.public.FriendRequest.where((p) => and(p.receiverId.eq(user.id), p.status.eq('PENDING')))
            .include("sender", (sender) => sender.select("username"))
            .select("id")
            .all()
        if (requestList) {
            console.log("Friend request API returns -> ", requestList)
            return res.status(200).json({ requests: requestList })
        }
        else {
            return res.status(500).json({ message: "No pending request found" })
        }
    } catch (e) {
        console.log('Error: ', e)
        return res.status(400).json({ message: "Internal server error" })
    }
}

/**
 * Friend request Accepted
 */
async function requestAccepted(req, res) {
    const { requestId } = req.body
    try {
        const updateRequest = db.orm.public.FriendRequest.where((p) => p.id.eq(requestId))
            .update({ status: 'ACCEPTED' })
        if (updateRequest != null) {
            return res.status(200).json({ message: "Updated request status to ACCEPTED" })
        } else {
            return res.status(401).json({ message: "Can not update request status" })
        }
    } catch (e) {
        return res.status(500).json({ message: "Internal server error" })
    }
}

/**
 * Friend Request Rejected
 */
async function requestRejected(req, res) {
    const { requestId } = req.body
    try {
        const updateRequest = db.orm.public.FriendRequest.where((p) => p.id.eq(requestId))
            .update({ status: 'REJECTED' })
        if (updateRequest != null) {
            return res.status(200).json({ message: "Updated request status to REJECTED" })
        } else {
            return res.status(401).json({ message: "Can not update request status" })
        }
    } catch (e) {
        return res.status(500).json({ message: "Internal server error" })
    }
}

/**
 * Fetch all the friends
 */
async function fetchFriends(req, res) {
    const user = req.user
    try {
        const friendRequests = await db.orm.public.FriendRequest.where((p) => and(
            or(
                p.senderId.eq(user.id), p.receiverId.eq(user.id)
            ),
            p.status.eq('ACCEPTED')
        ))
            .include("sender", (sender) => sender.select("username", "id"))
            .include("receiver", (receiver) => receiver.select("username", "id"))
            .select("senderId", "receiverId")
            .all()

        const friends = friendRequests.map((request) => {//request represents one friend request object at a time
            const friend = request.senderId === user.id ? request.receiver : request.sender
            return { friendsName: friend.username, friendsId: friend.id }
        })
        return res.status(200).json({ friends })
    } catch (e) {
        console.error('Error fetching friends:', e)
        return res.status(500).json({ message: 'Internal server error' })
    }
}

module.exports = { sendRequestController, fetchRequests, requestAccepted, requestRejected, fetchFriends }