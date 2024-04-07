import express from "express";
import bodyParser from "body-parser";
import cookieParser from "cookie-parser";
import dotenv from "dotenv";
import { dirname, join } from "path";
import { fileURLToPath } from "url";
import helmet from "helmet";
import authRoute from "./src/routes/authRoutes.js";
import {Server} from "socket.io";
import bcrypt from "bcrypt";
import mongoose from "mongoose";
import { Router } from "express";
const route = Router();


import connectDB from "./src/db/mongoose.js";
import { authenticateToken } from './src/middleware/authMiddleware.js';
import rateLimiter from './src/middleware/rateLimiterMiddleware.js';
import logoutRoute from "./src/routes/logoutroute.js";
import jwt from "jsonwebtoken";
import { start } from "repl";
import { Portal } from './src/models/portal.model.js';
import dataRoute from "./src/routes/dataRoute.js"

const app = express();



app.set('trust proxy', 20);
app.get('/ip', (request, response) => response.send(request.ip));
app.get('/x-forwarded-for', (request, response) => response.send(request.headers['x-forwarded-for']));
app.use(rateLimiter);
app.use('/', route);


app.use(logoutRoute);
app.use(dataRoute)
//static files folders
connectDB();
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(cookieParser());
dotenv.config();

const __dirname = dirname(fileURLToPath(import.meta.url));
const __public = dirname(__dirname) + "/public";



// Serve static files from the 'public/scripts' directory
app.use('/public', express.static(join(__dirname, '..', 'public')));
app.use('/scripts', express.static(join(__dirname, '..', 'public', 'scripts')));
app.use(express.static(__public));
// app.use(express.static("public/views"));

app.use(helmet.noSniff());
app.use(helmet.referrerPolicy({ policy: "no-referrer" }));

app.get("/", (req, res) => {
    res.sendFile(__public + "/views/home.html");
});

app.get("/signup", (req, res) => {
    res.sendFile(__public + "/views/sign_up.html");
});

app.get("/adminVerification", authenticateToken, (req, res) => {
    res.sendFile(__public + "/views/registerAuthority.html");
});

app.get("/login", (req, res) => {
    res.sendFile(__public + "/views/login.html");

});


app.get("/home", authenticateToken, (req, res) => {
    res.sendFile(__public + "/views/home.html");
});


app.get("/userLogin", authenticateToken, async (req, res) => {
    res.sendFile(__public + "/views/loginQuerier.html");
});

app.get("/adminLogin", authenticateToken, (req, res) => {
    res.sendFile(__public + "/views/loginAuthority.html");
});



app.get("/chat", authenticateToken, (req, res) => {
    res.sendFile(__public + "/views/chat.html");
})

app.post('/chat', authenticateToken, async (req, res) => {
    const receivedData = req.body.inputValue;

    const currentDate = new Date();
    const currentPortal = await Portal.findOneAndUpdate(
        { UID: req.user.UID, 'portals.querierId': req.user._id },
        {
            $push: {
                'portals.$.messages': receivedData
            }
        },
        {
            new: true // Return the modified document
        }
    );

    if (!currentPortal) {
        const newPortal = await Portal.create({
            UID: req.user.UID,
            portals: [{
                querierId: req.user._id,
                dateInitialized: currentDate,
                queryStatus: "pending",
                messages: [receivedData]
            }]
        });
        await newPortal.save()
    }
    

    res.sendStatus(200); // Send a success status code
});


app.get('/data', authenticateToken, async (req, res) => {
    let messages = [];
    // console.log(req.user.UID);

    const currentPortal = await Portal.find({ UID: req.user.UID });

    for (const portal of currentPortal) {
        const allPortals = portal.portals;
        for (const port of allPortals) {
            if (port.querierId == req.user._id) {
                messages = port.messages;
            }
        }
    }

    res.json({ data: messages });
});





app.use(authRoute);

app.listen(3000,()=>{
    console.log("Server started on port:3000");

})

