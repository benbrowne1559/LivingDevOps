Static Web App on EC2

Created a basic flask app with gunicorn
Opened up HTTP (80) and HTTPS (443) ports on ec2 security group
Installed nginx and started it on ec2
# Copy the nginx config to /etc/nginx/
``sudo cp nginx.conf /etc/nginx/conf.d/ec2webapp.conf``
# Test nginx configuration
``  sudo nginx -t ``

Allocate elastic IP to public ec2 instance
Create new type A record on domain registar side pointing to ec2 elastic IP
Update name servers on domain host side
# Setup flask app to run as systemd service
``
sudo nano /etc/systemd/system/ec2webapp.service
``
# Setup and Configure certbot
``
sudo dnf install -y certbot
sudo dnf install -y python3-certbot-nginx
``

Update nginx Configuration for HTTPS, reload nginx

# Run certbot
``sudo certbot --nginx -d benbrownedevops.xyz -d www.benbrownedevops.xyz``



![Infra Diagram](infra_diagram.png?raw=true "Infra Diagram")

