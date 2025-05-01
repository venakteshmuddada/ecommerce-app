#!/bin/bash
yum update -y
yum install -y git nodejs npm
cd /home/ec2-user
git clone https://github.com/venakteshmuddada/ecommerce-app.git
cd ecommerce-app/backend
npm install
node index.js &
