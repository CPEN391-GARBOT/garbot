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
       garbage: doc.data().garbage,
       compost: doc.data().compost,
       paper: doc.data().paper,
       plastic: doc.data().plastic,
       });
   }

});


//POST request-give me 1,2,3, or 4 and the user (add to stats and manual open garbage cans)
router.post("/:canID", async (req,res,next) => {
   const id = req.params.canID;
   const user = req.body.username;
   const ref = app.db.collection('garbage').doc(user);
   if(id == "1"){
       const result = await ref.update({
           garbage: app.admin.firestore.FieldValue.increment(1)
           });
           res.json({});
           piblaster.setPwm(23,.1); 
           await new Promise(resolve => setTimeout(resolve, 50));
           piblaster.setPwm(23,0);
   } else if (id == "2") {
       const result = await ref.update({
           compost: app.admin.firestore.FieldValue.increment(1)
           });
           res.json({});
           piblaster.setPwm(22,.1);
           await new Promise(resolve => setTimeout(resolve, 50));
           piblaster.setPwm(22,0);
   } else if (id == "3"){
        const result = await ref.update({
           paper: app.admin.firestore.FieldValue.increment(1)
           });
           res.json({});
           piblaster.setPwm(18,.1);
           await new Promise(resolve => setTimeout(resolve, 50));
           piblaster.setPwm(18,0);
   } else if (id == "4"){
       const result = await ref.update({
           plastic: app.admin.firestore.FieldValue.increment(1)
           });
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