#!/bin/bash

# Let's Encrypt 인증서 발급 스크립트 (3개 도메인)

echo "Stopping nginx container..."
docker-compose down

echo "Issuing certificate for all domains..."
sudo certbot certonly --standalone \
  -d dev-app.climingo.xyz \
  -d dev-api.climingo.xyz \
  -d api.climingo.xyz \
  --non-interactive \
  --agree-tos \
  --email admin@climingo.xyz

echo "Copying certificates..."
sudo cp /etc/letsencrypt/live/dev-app.climingo.xyz/fullchain.pem ./ssl/letsencrypt-fullchain.pem
sudo cp /etc/letsencrypt/live/dev-app.climingo.xyz/privkey.pem ./ssl/letsencrypt-privkey.pem
sudo chmod 644 ./ssl/letsencrypt-fullchain.pem
sudo chmod 644 ./ssl/letsencrypt-privkey.pem

echo "Starting nginx container..."
docker-compose up -d

echo "Certificate issuance completed!"
