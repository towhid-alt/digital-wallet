const express = require("express")
const { db } = require("../prisma/db.ts")
//const { and } = require("@prisma/orm-postgres/orm-client")

async function createAccountController(req, res) {
    const user = req.user
    try{
        const account= db.orm.public.User.create({
            userId: user.id
        })
        res.status(200).json({message:"Account created successfully"})
    } catch(e){
        console.log("Error: ",e)
        res.status(501).json({message:"Internal server error"})
    }
}

module.exports = { createAccountController }