const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// MySQL config
const mysqlConfig = {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
};

let con = null;

// Initialize DB connection
const databaseInit = () => {
  con = mysql.createConnection(mysqlConfig);
  con.connect((err) => {
    if (err) {
      console.error("Error connecting to DB:", err);
      return;
    }
    console.log("Connected to the database");
  });
};

// Create database if not exists
const createDatabase = () => {
  con.query(
    `CREATE DATABASE IF NOT EXISTS ${mysqlConfig.database}`,
    (err) => {
      if (err) {
        console.error("Error creating database:", err);
      } else {
        console.log("Database ensured");
      }
    }
  );
};

// Create table if not exists
const createTable = () => {
  con.query(
    `CREATE TABLE IF NOT EXISTS apptb (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(255)
    )`,
    (err) => {
      if (err) {
        console.error("Error creating table:", err);
      } else {
        console.log("Table apptb ensured");
      }
    }
  );
};

// ---------------- ROUTES ----------------

// GET users
app.get("/api/users", (req, res) => {
  con.query("SELECT * FROM apptb", (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).send("Error retrieving data from database");
    } else {
      res.json(results);
    }
  });
});

// POST user
app.post("/api/user", (req, res) => {
  con.query(
    "INSERT INTO apptb (name) VALUES (?)",
    [req.body.data],
    (err, results) => {
      if (err) {
        console.error(err);
        res.status(500).send("Error inserting data");
      } else {
        res.json(results);
      }
    }
  );
});

// ------------ STARTUP SEQUENCE ------------

// 1. Connect DB
databaseInit();

// 2. Ensure DB & table
createDatabase();
createTable();

// 3. Start server
app.listen(3000, "0.0.0.0", () => {
  console.log("Server running on port 3000");
});

