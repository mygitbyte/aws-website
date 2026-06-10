#!/bin/bash
# User-data executed on first boot. Installs nginx and syncs the site from S3.
yum update -y
amazon-linux-extras install -y nginx1
yum install -y awscli
systemctl enable nginx

# Replace BUCKETNAME and REGIONNAME via deploy script
aws s3 sync s3://BUCKETNAME /usr/share/nginx/html --region REGIONNAME
chown -R nginx:nginx /usr/share/nginx/html
systemctl start nginx
