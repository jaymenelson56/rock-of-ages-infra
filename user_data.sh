#!/bin/bash
yum update -y

# Install Docker
dnf install docker -y
service docker start
usermod -a -G docker ec2-user

# Reconnect permissions later
newgrp docker 