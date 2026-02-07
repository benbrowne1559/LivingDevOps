Static Web App on EC2

Created a basic flask app with gunicorn
Opened up HTTP (80) and HTTPS (443) ports on ec2 security group
Installed nginx and started it on ec2
# Copy the nginx config to the sites-available directory
  sudo cp /home/ubuntu/EC2WebApp/nginx.conf /etc/nginx/sites-available/ec2webapp

# Create a symbolic link to enable the site
  sudo ln -s /etc/nginx/sites-available/ec2webapp /etc/nginx/sites-enabled/


