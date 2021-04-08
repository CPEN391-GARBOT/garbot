const express = require("express")
const router = express.Router();
var app = require("../app");

//GET request for password
router.get("/:userID", async (req,res,next) => {
   const id = req.params.userID;
   const garb = app.db.collection('garbage').doc(id);
   const doc = await garb.get();
   var result = 0;
   if(!doc.exists) {
       console.log("User Doesn't exist");
       result = 1;
   }
   if (result == 0) {
       res.json({
           password: doc.data().password
       });
   } else {
     res.json({});
   }
  
});


//POST request for making new account {username:,password:}
router.post("", async (req,res,next) => {
   const username = req.body.username;
   const password = req.body.password;
   const data = {
    username: username,
    password: password,
    stats: [],
   };
   console.log("user created");
   
   const result = app.db.collection('garbage').doc(username).set(data);
   res.json({});
           
});

module.exports = router;