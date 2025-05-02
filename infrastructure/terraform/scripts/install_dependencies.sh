#!/bin/bash
cd /home/ec2-user/app
npm install
npm install -g pm2
pm2 start index.js
resource "aws_launch_template" "app_template" {
  # … existing args …

  # Force a new version when user_data changes
  lifecycle {
    create_before_destroy = true
  }
}
