#!/bin/bash
cd /home/ec2-user/ecommerce-app/backend
nohup node index.js > /home/ec2-user/backend.log 2>&1 &
