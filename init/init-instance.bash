#!/bin/bash

curl -fsSL https://get.docker.com | sh
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo gpasswd -a ubuntu docker
sudo chown ubuntu /usr/local/bin/docker-compose
sudo -u ubuntu chmod +x /usr/local/bin/docker-compose
sudo systemctl reboot
