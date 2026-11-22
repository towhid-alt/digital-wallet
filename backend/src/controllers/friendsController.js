const express = require('express')
const { db } = require('../prisma/db.ts')
const { and, or } = require("@prisma/orm-postgres/orm-client")
const redis = require('../client')

const FRIENDS_CACHE_TTL_SECONDS = 300

function friendsCacheKey(userId) {
    return `friends:${userId}`
}

async function invalidateFriendsCache(userIds) {
    try {
        await redis.del(...userIds.map(friendsCacheKey))//Spread operator
    } catch (error) {
        console.error('Error invalidating friends cache:', error)
    }
}

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
        const requestList = await db.orm.public.FriendRequest.where((p) => and(p.receiverId.eq(user.id), p.status.eq('PENDING')))
            .include("sender", (sender) => sender.select("username"))
            .select("id")
            .all()
        if (requestList) {
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
        const request = await db.orm.public.FriendRequest.where((p) => p.id.eq(requestId))
            .select("senderId", "receiverId")
            .first()
        if (!request) {
            return res.status(404).json({ message: "Friend request not found" })
        }

        await db.orm.public.FriendRequest.where((p) => p.id.eq(requestId))
            .update({ status: 'ACCEPTED' })
        await invalidateFriendsCache([request.senderId, request.receiverId])
        return res.status(200).json({ message: "Updated request status to ACCEPTED" })
    } catch (e) {
        console.error('Error accepting friend request:', e)
        return res.status(500).json({ message: "Internal server error" })
    }
}

/**
 * Friend Request Rejected
 */
async function requestRejected(req, res) {
    const { requestId } = req.body
    try {
        const request = await db.orm.public.FriendRequest.where((p) => p.id.eq(requestId))
            .select("senderId", "receiverId")
            .first()
        if (!request) {
            return res.status(404).json({ message: "Friend request not found" })
        }

        await db.orm.public.FriendRequest.where((p) => p.id.eq(requestId))
            .update({ status: 'REJECTED' })
        await invalidateFriendsCache([request.senderId, request.receiverId])
        return res.status(200).json({ message: "Updated request status to REJECTED" })
    } catch (e) {
        console.error('Error rejecting friend request:', e)
        return res.status(500).json({ message: "Internal server error" })
    }
}

/**
 * Fetch all the friends
 */
async function fetchFriends(req, res) {
    const user = req.user
    const cacheKey = friendsCacheKey(user.id)
    try {
        try {
            const cachedFriends = await redis.get(cacheKey)
            if (cachedFriends !== null) {
                const friends = JSON.parse(cachedFriends)
                if (Array.isArray(friends)) {
                    return res.status(200).json({ friends, currentUserId: user.id })
                }
                console.error('Invalid friends cache value; fetching friends from database')
                await redis.del(cacheKey)
            }
        } catch (error) {
            console.error('Error reading friends cache:', error)
        }

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

        try {
            await redis.set(
                cacheKey,
                JSON.stringify(friends),
                'EX',
                FRIENDS_CACHE_TTL_SECONDS
            )
        } catch (error) {
            console.error('Error caching friends:', error)
        }
        return res.status(200).json({ friends, currentUserId: user.id })
    } catch (e) {
        console.error('Error fetching friends:', e)
        return res.status(500).json({ message: 'Internal server error' })
    }
}

module.exports = { sendRequestController, fetchRequests, requestAccepted, requestRejected, fetchFriends }