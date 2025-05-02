#!/bin/bash
# Run as root

# 1) Install runtime dependencies
yum update -y
amazon-linux-extras install -y epel
yum install -y git nodejs npm ruby wget

# 2) Install & start CodeDeploy agent
cd /home/ec2-user
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
./install auto
systemctl enable codedeploy-agent
systemctl start codedeploy-agent

# 3) Clone your repo into ec2-user’s home, ensure ownership
cd /home/ec2-user
rm -rf ecommerce-app
git clone https://github.com/venakteshmuddada/ecommerce-app.git
chown -R ec2-user:ec2-user ecommerce-app

# 4) Install & launch the backend under ec2-user
sudo -u ec2-user bash << 'EOF'
  cd /home/ec2-user/ecommerce-app/backend
  npm install
  nohup node index.js > app.log 2>&1 &
EOF
