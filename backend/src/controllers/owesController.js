const express = require('express')
const { db } = require('../prisma/db.ts')

async function deleteOwe(req, res) {
    const oweId= req.oweId
//TODO: Stale cache data. Update redis data when owe status is updated
    try{
        const rejectedOwe = db.orm.public.Owes.where({ id: oweId })
        .update({ status: "REJECTED" })
        return res.status(200).json({message: "Owe rejected"})
    } catch(e){
        console.error("Error updating owe to REJECTED")
        return res.status(401).json({ message: "Error updating owe to REJ"})
    }
}

async function oweAccept(req, res) {
    const oweId= req.oweId

    try{
        const acceptOwe = db.orm.public.Owes.where({ id: oweId })
        .update({ status: "ACCEPTED" })
        return res.status(200).json({message: "Owe accepted"})
    } catch(e){
        console.error("Error updating owe to Accepted")
        return res.status(401).json({ message: "Error updating owe to ACCEPTED"})
    } 
}

module.exports = {deleteOwe, oweAccept}