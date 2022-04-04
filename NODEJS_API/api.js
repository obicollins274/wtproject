const functions = require("firebase-functions");
const admin = require("firebase-admin");
const express = require("express");
const cors = require("cors");
const jwt = require("jsonwebtoken");
const apps = express();

admin.initializeApp({
  credential: admin.credential.cert(require("./serviceaccount.json")),
});

apps.use(express.json());
apps.use(cors({origin: true}));
const db = admin.firestore();

// endpoint for loop signup
apps.post("/sign_up", (req, res) => {
  const {userid, firstname, lastname, username,
    password, dateofreg, timestamp} = req.body;
  const entryconn = db.collection("mainDB").doc(username);

  try {
    const token = jwt.sign({password}, "loopwt");
    const regData = {
      userid,
      firstname,
      lastname,
      username,
      password: token,
      dateofreg,
      timestamp,
    };

    entryconn.get().then((documentSnapshot) => {
      if (documentSnapshot.exists) {
        return res.status(409).send({status: "Username already exist."});
      } else {
        entryconn.set(regData);
        res.status(200).send({
          status: "success",
          message: "registration was successful",
          data: regData});
      }
    });
  } catch (error) {
    res.status(500).json(error.message);
  }
});

// endpoint for user login
apps.post("/login", (req, res) => {
  try {
    const {username, password} = req.body;
    db.collection("mainDB").doc(username).get().then((documentSnapshot) => {
      const newdata = documentSnapshot.data();
      if (documentSnapshot.exists) {
        const token = newdata.password;
        const decoded = jwt.decode(token, "loopwt");
        const encpassword = decoded.password;
        if (encpassword == password) {
          res.status(200).send({status: "success"});
        } else {
          res.status(409).send({status: "Invalid login details"});
        }
      } else {
        return res.status(400).send({status: "User does not exist"});
      }
    });
  } catch (error) {
    return res.status(500).json(error.message);
  }
});

// endpoint for saving weight
apps.post("/save_weight", (req, res) => {
  const {username, weight, dateofreg, timestamp} = req.body;
  const entryconn = db.collection("mainDB").doc(username);
  try {
    const regData = {username, weight, dateofreg, timestamp};
    entryconn.get().then((documentSnapshot) => {
      if (documentSnapshot.exists) {
        entryconn.collection("weighthistory").doc(timestamp).set(regData);
        res.status(200).send({
          status: "success",
          message: "registration was successful",
          data: regData});
      } else {
        return res.status(400).send({status: "Username does not exist"});
      }
    });
  } catch (error) {
    res.status(500).json(error.message);
  }
});

// endpoint for weight history
apps.post("/get_weight_history", (req, res) => {
  const {username} = req.body;
  const getconn = db.collection("mainDB").doc(username)
      .collection("weighthistory").orderBy("timestamp", "desc").get();
  try {
    const allData = [];
    if (getconn.empty) {
      res.status(500).send({status: "Database connection failed"});
    } else {
      getconn.then((querySnapshot) => {
        querySnapshot.forEach((doc) => {
          const singleDoc = doc.data();
          allData.push(singleDoc);
        });
        res.status(200).json(allData);
      });
    }
  } catch (error) {
    return res.status(500).json(error.message);
  }
});

// endpoint for update weight
apps.post("/update_weight", (req, res) => {
  try {
    const {username, weight, timestamp} = req.body;
    const updateconn = db.collection("mainDB").doc(username)
        .collection("weighthistory").doc(timestamp).update({weight: weight});
    updateconn.get().then((documentSnapshot) => {
      if (documentSnapshot.exists) {
        return res.status(200).send({status: "success"});
      } else {
        return res.status(400).send({status: "Record does not exist"});
      }
    });
  } catch (error) {
    return res.status(500).json(error.message);
  }
});

// endpoint to delete weight
apps.post("/delete_weight", (req, res) => {
  try {
    const {username, timestamp} = req.body;
    const deleteconn = db.collection("mainDB").doc(username)
        .collection("weighthistory").doc(timestamp).delete();
    deleteconn.then((value) => {
      return res.status(200).send({status: "success"});
    });
  } catch (error) {
    return res.status(500).json(error.message);
  }
});
exports.api = functions.https.onRequest(apps);
