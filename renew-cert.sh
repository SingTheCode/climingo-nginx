#!/bin/bash
set -e  # 에러 발생 시 즉시 중단

# Let's Encrypt 인증서 갱신 스크립트

echo "Stopping nginx container..."
cd /Users/singco/dev/climingo/nginx
docker-compose down

echo "Waiting for port to be released..."
sleep 5

echo "Renewing certificate..."
sudo certbot renew --standalone

echo "Copying certificates..."
sudo cp /etc/letsencrypt/live/dev-app.climingo.xyz/fullchain.pem ./ssl/letsencrypt-fullchain.pem
sudo cp /etc/letsencrypt/live/dev-app.climingo.xyz/privkey.pem ./ssl/letsencrypt-privkey.pem
sudo chmod 644 ./ssl/letsencrypt-fullchain.pem
sudo chmod 604 ./ssl/letsencrypt-privkey.pem

echo "Starting nginx container..."
docker-compose up -d --build

echo "Certificate renewal completed!"
