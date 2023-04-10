#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
#cat " APPLICATION Hosted !!" >> /var/www/html/app.html
sudo systemctl start httpd
sudo systemctl enable httpd
#chkconfig httpd on