const express = require("express")
const { db } = require("../prisma/db.ts")
const { and, or } = require("@prisma/orm-postgres/orm-client")
const redis = require('../client.js')

const FETCH_CACHE_EX_SECONDS = 300

function fetchCacheKey(currentUserId, receiverId) {
    const ids = [currentUserId, receiverId].sort((a,b) => a-b)
    return `chats:${ids[0]}:${ids[1]}`
}
/**
 * Fetch chats
 */
async function fetchChats(req, res) {
    const currentUserId = req.query.currentUserId
    const receiverId = req.query.receiverId
    const cacheKey = fetchCacheKey(currentUserId, receiverId)

    try {
        /**
         * Fetching from cache
         */
        try{
            const cachedChats = await redis.get(cacheKey)
            if(cachedChats != null) {
                const chats = JSON.parse(cachedChats)
                if(Array.isArray(chats)){
                    return res.status(200).json(chats)
                }
                console.error('Invalid chats cache value; fetching from database')
            redis.del(cacheKey)
            }
            
        } catch (error){
            console.error('Error reading friends cache: ',error)
        }
        /**
         * DB call
         */
        const chats = await db.orm.public.Owes.where((p) => or(
            and(p.senderId.eq(currentUserId), p.receiverId.eq(receiverId)),
            and(p.senderId.eq(receiverId), p.receiverId.eq(currentUserId)))).all()
        //console.log('Result of DB call: ',chats)
         if(chats){
            /**
          * Caching chats
          */
         try{
            await redis.set(
                cacheKey, JSON.stringify(chats),'EX',
                FETCH_CACHE_EX_SECONDS
            )
         } catch(e){
            console.error('Error caching friends: ',error)
         }
            return res.status(200).json(chats)
         }else {
            return res.status(302).json({message: 'No chat found'})
         }

         
    } catch(e) {
        return res.status(400).json({message: "Internal server error"})
    }
}



module.exports = { fetchChats, fetchCacheKey }