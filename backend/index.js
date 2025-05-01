const express = require('express');
const app = express();
const port = 3000;
const mysql = require('mysql');
const AWS = require('aws-sdk');

// Set region for Secrets Manager
AWS.config.update({ region: process.env.AWS_REGION || 'us-east-1' });
const secretsManager = new AWS.SecretsManager();

// Fetch DB credentials from Secrets Manager
async function getDBCredentials() {
  try {
    const secretValue = await secretsManager.getSecretValue({
      SecretId: 'ecommerce-db-credentials'
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
  const credentials = await getDBCredentials();
  const connection = mysql.createConnection({
    host: 'terraform-20250430190138256300000001.c2bcyuiw61ub.us-east-1.rds.amazonaws.com',
    user: credentials.username,
    password: credentials.password,
    database: 'your-database-name-here'
  });

  connection.connect((err) => {
    if (err) {
      console.error('❌ Error connecting to DB:', err);
    } else {
      console.log('✅ Connected to RDS DB!');
    }
  });
}

connectDB();

app.get('/', (req, res) => {
  res.send('✅ Ecommerce Backend is running!');
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${port}`);
});
<<<<<<< HEAD
=======

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
// deploy trigger
// deploy trigger
// deploy trigger
// deploy trigger
// deploy trigger
// deploy trigger
// deploy trigger
>>>>>>> d1e402c (Trigger deploy)
// deploy trigger
// deploy trigger
