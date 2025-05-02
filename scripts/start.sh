#!/bin/bash
cd /home/ec2-user/ecommerce-app/backend
export AWS_REGION=us-east-1
nohup node index.js > ~/backend.log 2>&1 &
