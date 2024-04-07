import express from "express";
const router = express.Router();
import { authenticateToken } from "../middleware/authMiddleware.js";
import { Portal } from '../models/portal.model.js';


router.get('/data',authenticateToken, async (req,res)=>{
    const UID = req.user.UID;
    const userId = req.user._id;
    const messages = [];
    console.log(req.user.UID)

    const currentPortal = await Portal.find({ UID: UID, })
    console.log(currentPortal)
    const allPortals = currentPortal.portals

    for(port of allPortals){
        if (port.querierId == req.user._id) {
            messages = port.messages
        }
    }

    res.json({data: messages})
})

export default router;