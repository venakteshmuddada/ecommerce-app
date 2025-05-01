const express = require('express');
const app = express();
const port = 3000;
const mysql = require('mysql');
const AWS = require('aws-sdk');
const secretsManager = new AWS.SecretsManager();

// Fetch DB credentials from Secrets Manager
async function getDBCredentials() {
  try {
    const secretValue = await secretsManager.getSecretValue({
      SecretId: 'ecommerce-db-credentials'  // The secret name from Secrets Manager
    }).promise();

    const secret = JSON.parse(secretValue.SecretString);
    return {
      username: secret.username,
      password: secret.password
    };
  } catch (error) {
    console.error("Error retrieving secret:", error);
    throw error;
  }
}

// Setup MySQL connection
async function connectDB() {
  const credentials = await getDBCredentials();  // Get DB credentials from Secrets Manager
  const connection = mysql.createConnection({
    host: 'your-db-host',  // The DB host (endpoint from RDS or similar)
    user: credentials.username,  // The username from Secrets Manager
    password: credentials.password,  // The password from Secrets Manager
    database: 'your-database'  // Your DB name
  });

  connection.connect((err) => {
    if (err) {
      console.error('Error connecting to DB:', err);
    } else {
      console.log('Connected to DB!');
    }
  });
}

// Call DB connection when the app starts
connectDB();

app.get('/', (req, res) => {
  res.send('✅ Ecommerce Backend is running!');
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${port}`);
});

// trigger deploy
// trigger new deploy
// deploy trigger
// deploy new trigger
// deploy new trigger
// deploy new trigger
// deploy new trigger
// deploy trigger
// deploy trigger
// deploy trigger
// deploy trigger
// deploy trigger
