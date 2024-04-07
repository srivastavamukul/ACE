import express from "express";
import { dirname, join } from "path";
import { fileURLToPath } from "url";
import { Portal } from '../models/portal.model.js';
import { authenticateToken } from "../middleware/authMiddleware.js";


const __dirname = dirname(fileURLToPath(import.meta.url));
const router = express.Router();
const publicPath = join(__dirname, "../../../public"); // Go two folders back and then to public folder
const viewsPath = join(publicPath, "views"); // Inside public folder

// router.get('/chatbot', (req, res) => {
//     const chatFilePath = join(viewsPath, "chat.html"); // Inside views folder
//     res.sendFile(chatFilePath);
// });



router.use(express.json());

router.post('/chatBot', authenticateToken, async (req, res) => {
    console.log(req.user);
    const receivedData = req.body.inputValue;
    console.log('Received data:', receivedData);



    // const currentPortal = await Portal.find({UID: uid})
    // const allPortals = currentPortal.portals
    
    // const obj = {
    //     content: receivedData
    // }

    // for(port of allPortals){
    //     if(port.querierId == querierId){

    //         port.messages.push(obj)
    //     }
    // }

    // await currentPortal.save();

    res.sendStatus(200); // Send a success status code
});





export default router;