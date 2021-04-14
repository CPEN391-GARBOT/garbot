const express = require("express");
const piblaster = require('pi-blaster.js');
const router = express.Router();
var app = require("../app");

//GET request for stats
router.get("/:userID", async (req,res,next) => {
    const id = req.params.userID;
    const garb = app.db.collection('garbage').doc(id);
   const doc = await garb.get();
   if(!doc.exists) {
       console.log("User Doesn't exist");
       res.json({});
   } else {
       res.json({
       stats: doc.data().stats,
       timestamps: doc.data().timestamps
       });
   }

});


//POST request-give me 1,2,3, or 4 and the user (add to stats and manual open garbage cans)
router.post("/:canID", async (req,res,next) => {
   const id = req.params.canID;
   const user = req.body.username;
   const quantity = req.body.quantity;
   const timestamp = parseInt(req.body.timestamp);
   const ref = app.db.collection('garbage').doc(user);
   var j = 0;
   timestamp
   for (i = 0; i < parseInt(quantity); i++) {
       const result = await ref.update({
           stats: app.admin.firestore.FieldValue.arrayUnion({can: id, timestamp:timestamp+j})
           });
           j += .17;
        }
   if(id == "1"){
           res.json({});
           piblaster.setPwm(23,5);
           await new Promise(resolve => setTimeout(resolve, 50));
           piblaster.setPwm(23,10);
   } else if (id == "2") {
           res.json({});
           piblaster.setPwm(22,5);
           await new Promise(resolve => setTimeout(resolve, 50));
           piblaster.setPwm(22,10);
   } else if (id == "3"){
           res.json({});
           piblaster.setPwm(18,5);
           await new Promise(resolve => setTimeout(resolve, 50));
           piblaster.setPwm(18,10);
   } else if (id == "4"){
           res.json({});
           piblaster.setPwm(4,.2);
           await new Promise(resolve => setTimeout(resolve, 60));
           piblaster.setPwm(4,0);
           await new Promise(resolve => setTimeout(resolve, 3000));
           piblaster.setPwm(4,.1);
           await new Promise(resolve => setTimeout(resolve, 60));
           piblaster.setPwm(4,0);
   } else {
    res.json({
        message: "User does not exist"
    });
   }

});

module.exports = router;
