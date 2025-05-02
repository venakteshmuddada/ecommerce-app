#!/bin/bash
pkill node || true
rm -rf /home/ec2-user/app
mv /home/ec2-user/deploy_temp /home/ec2-user/app
cd /home/ec2-user/app/backend
export AWS_REGION=us-east-1
nohup node index.js > ~/backend.log 2>&1 &
