#!/bin/bash

sleep 30

echo "installing git" > install.log
sudo yum install git -y
sudo yum install nginx -y

git clone https://github.com/benbrowne1559/LivingDevOps.git

cd LivingDevOps/EC2WebApp/

sudo chmod +x start_app.sh
sudo cp systemd_config.txt /etc/systemd/system/ec2webapp.service

sudo systemctl daemon-reload
sudo systemctl enable ec2webapp.service
sudo systemctl start ec2webapp.service


