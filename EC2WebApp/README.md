# Static Web App on EC2

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

# Web App on EC2 with Load Balancer and Auto Scaling Group + Route53

The static web app is now configured within a target group, which is managed by an Auto Scaling group (ASG). The ASG creates or destroys ec2 instances based on load levels. 

1) The instances are created via a launch template which installs dependancies, the repo and starts the web app as a service on port 8000.
2) The Application Load Balancer sits in 2 availability zones / public subnets, accepts traffic on ports 80/443 and allows traffic out on port 8000
3) ASG allows inbound traffic on port 8000

Domain Setup:
1) Created a hosted zone for my domain in Route53 and copied over AWS name servers to my domain registrar
2) Created an alias that points to the ALB
3) Created a certificate via ACM and validate by adding CNAME records to hosted zone
4) For ALB, redirect HTTP traffic to HTTPS and add certificate to HTTPS listener

![Infra Diagram2](infra_diagram_alb.png?raw=true "Infra Diagram with ALB")
