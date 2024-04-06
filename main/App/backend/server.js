const express = require("express");
const mongoose = require("mongoose");
const bodyParser = require("body-parser");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const socket = require("socket.io");
const route = require("express").Router();
const http = require("http");

const app = express();
const server = http.createServer(app);
const io = socket(server);

const port = process.env.PORT || 3000;

app.use(bodyParser.json());
app.use("/", route);
server.listen(port, () => {
  console.log(`your server is running on http://localhost:${port}`);
});

io.on("connection", (socket) => {
  console.log("connected to", socket.id);
  socket.on("disconnect", () => {
    console.log("disconnected from", socket.id);
  });

  socket.on("new", (data) => {
    console.log(data);
    socket.emit("build", "rebuild");
  });
});

app.get("/", function (req, res) {
  res.send("your server running perfect");
  e;
});

mongoose
  .connect("mongodb://localhost:27017/hackbyte")
  .then(() => {
    console.log("Mongodb Connected");
  })
  .catch((error) => {
    console.log(error);
  });

const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
});

const roomSchema = new mongoose.Schema({
  room: {
    type: String,
    required: true,
  },
  chats: [
    {
      _id: {
        type: String,
        required: true,
      },
      status: {
        type: String,
        required: true,
        enum: ["pending", "active", "closed"],
      },
      subject: {
        type: String,
        required: true,
      },
      message: {
        type: String,
        required: true,
      },
    },
  ],
});

userSchema.pre("save", async function () {
  try {
    const salt = await bcrypt.genSalt(10);
    const hashPass = await bcrypt.hash(this.password, salt);
    this.password = hashPass;

    const hashMail = await bcrypt.hash(this.email, salt);
    this.email = hashMail;
  } catch (error) {
    console.log(error);
  }
});

const userModel = mongoose.model("user", userSchema);
const roomModel = mongoose.model("room", roomSchema);

async function findUser(username) {
  try {
    return await userModel.findOne({ username: username });
  } catch (error) {
    console.log(error);
  }
}

async function findRoom(room) {
  try {
    return await roomModel.findOne({ room: room });
  } catch (error) {
    console.log(error);
  }
}

async function generateToken(tokenData, secretKey, jwt_expire) {
  return jwt.sign(tokenData, secretKey, { expiresIn: jwt_expire });
}

async function registerUser(username, email, password) {
  try {
    const createUser = userModel({ username, email, password });
    return await createUser.save();
  } catch (error) {
    console.log(error);
  }
}
async function countPending(req, res, next) {
  const { _id } = req.body;
  try {
    const pending = await roomModel.aggregate([
      {
        $unwind: "$chats",
      },
      {
        $match: {
          "chats._id": _id,
          "chats.status": "pending",
        },
      },
      {
        $group: {
          _id: null,
          count: { $sum: 1 },
        },
      },
    ]);

    res
      .status(200)
      .send({
        status: true,
        pending: pending.length > 0 ? pending[0].count : 0,
      });
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: "Internal server error" });
  }
}

async function countOngoing(req, res, next) {
  const { _id } = req.body;
  try {
    const ongoing = await roomModel.aggregate([
      {
        $unwind: "$chats",
      },
      {
        $match: {
          "chats._id": _id,
          "chats.status": "active",
        },
      },
      {
        $group: {
          _id: null,
          count: { $sum: 1 },
        },
      },
    ]);

    res
      .status(200)
      .send({
        status: true,
        ongoing: ongoing.length > 0 ? ongoing[0].count : 0,
      });
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: "Internal server error" });
  }
}

async function countClosed(req, res, next) {
  const { _id } = req.body;
  try {
    const closed = await roomModel.aggregate([
      {
        $unwind: "$chats",
      },
      {
        $match: {
          "chats._id": _id,
          "chats.status": "closed",
        },
      },
      {
        $group: {
          _id: null,
          count: { $sum: 1 },
        },
      },
    ]);

    res
      .status(200)
      .send({ status: true, closed: closed.length > 0 ? closed[0].count : 0 });
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: "Internal server error" });
  }
}

async function countStash(req, res, next) {
  const { _id } = req.body;
  try {
    const stash = await roomModel.aggregate([
      {
        $unwind: "$chats",
      },
      {
        $match: {
          "chats._id": _id,
        },
      },
      {
        $group: {
          _id: null,
          count: { $sum: 1 },
        },
      },
    ]);

    res
      .status(200)
      .send({ status: true, stash: stash.length > 0 ? stash[0].count : 0 });
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: "Internal server error" });
  }
}

async function register(req, res, next) {
  try {
    const { username, email, password } = req.body;
    const success = await registerUser(username, email, password);

    if (success) {
      const tokenData = { _id: success._id, username: success.username };
      const token = await generateToken(tokenData, "hackbyte", "1h");

      res.json({ status: true, token: token });
    } else {
      res.json({ status: false, success: "user not registered successfully" });
    }
  } catch (error) {
    console.log(error);
  }
}

async function login(req, res, next) {
  const { username, email, password } = await req.body;

  const user = await findUser(username);

  if (!user) {
    console.log("user not found");
  } else {
    if (await bcrypt.compare(password, user.password)) {
      if (await bcrypt.compare(email, user.email)) {
        const tokenData = { _id: user._id, username: user.username };
        const token = await generateToken(tokenData, "hackbyte", "1h");

        res.status(200).send({ status: true, token: token });
      } else {
        console.log("email/password does not match");
        res
          .status(401)
          .send({ status: false, error: "email/password does not match" });
      }
    } else {
      console.log("email/password does not match");
      res
        .status(401)
        .send({ status: false, error: "email/password does not match" });
    }
  }
}

async function joinRoom(req, res, next) {
  const { room } = await req.body;
  const roomdata = await findRoom(room);

  if (!roomdata) {
    console.log("no such room exists");
  } else {
    res.status(200).json({ status: true, UID: room });
  }
}

async function pushChat(req, res, next) {
  const { _id, status, subject, message, room } = req.body;
  const roomData = await findRoom(room);

  if (!roomData) {
    console.log("room does not exist");
  } else {
    const data = {
      _id: _id,
      status: status,
      subject: subject,
      message: message,
    };

    roomData.chats.push(data);
    await roomData.save();

    res.status(200).json({ status: true, success: "chats pushed" });
  }
}

async function ChatsFetch(req, res, next) {
  const { room } = req.body;
  const roomdata = await findRoom(room);
  if (!roomdata) {
    console.log("room does not exist");
  } else {
    res.status(200).send(roomdata.chats);
  }
}

route.post("/register", register);
route.post("/login", login);
route.post("/room", joinRoom);
route.post("/chat", pushChat);
route.post("/fetch", ChatsFetch);
route.post("/countClosed", countClosed);
route.post("/countPending", countPending);
route.post("/countOngoing", countOngoing);
route.post("/countStash", countStash);
