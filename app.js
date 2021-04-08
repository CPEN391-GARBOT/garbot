const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const piblaster = require('pi-blaster.js');

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

var garbageRoutes = require("./routes/garbageService");
var userRoutes = require("./routes/userService");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
 });
 
const db = admin.firestore();
piblaster.setPwm(4,0.0); 
piblaster.setPwm(18,0);
piblaster.setPwm(22,0);
piblaster.setPwm(23,0);

app.use(bodyParser.urlencoded({extended: false}));
app.use(bodyParser.json());

app.use((req,res,next) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "*");
    if(req.method === "OPTION") {
        res.header("Access-Control-Allow-Methods", "PUT, POST, GET, DELETE, PATCH");
        return res.status(200).json({});
    }
    next();
});

app.use("/garbage", garbageRoutes);
app.use("/user", userRoutes);

app.use((req,res,next) => {
    const error = new Error("not found");
    error.status = 404;
    next(error);
});

app.use((error,req,res,next) => {
    res.status(error.status || 500);
    res.json({
        error: {
            message: error.message,
            status: error.status
        }
    });
});

exports.app = app;
exports.db = db;
exports.admin = admin;