#!/bin/bash
yum update -y
yum install -y git
curl -sL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Clone your app repo
cd /home/ec2-user
git clone https://github.com/venakteshmuddada/ecommerce-app.git
cd ecommerce-app/backend
npm install
npm run start &
