#!/bin/bash

# Log everything
exec > >(tee /var/log/launch_template.log)
exec 2>&1

sleep 30

echo "installing git" > install.log
sudo yum install git -y

cd /home/ec2-user
git clone https://github.com/benbrowne1559/LivingDevOps.git

cd LivingDevOps/2Tier-EC2WebApp/
sudo chown -R ec2-user:ec2-user /home/ec2-user/LivingDevOps/

sudo chmod +x start_app.sh
sudo touch /var/log/ec2webapp.log
sudo chown ec2-user:ec2-user /var/log/ec2webapp.log

sudo cp systemd_config.txt /etc/systemd/system/ec2webapp.service

sudo systemctl daemon-reload
sudo systemctl enable ec2webapp.service
sudo systemctl start ec2webapp.service

