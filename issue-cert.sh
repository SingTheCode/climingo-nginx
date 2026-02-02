#!/bin/bash

# Let's Encrypt 인증서 발급 스크립트

echo "Stopping nginx container..."
docker-compose down

echo "Issuing certificate for climingo.xyz domains..."
sudo certbot certonly --standalone \
  -d dev-app.climingo.xyz \
  -d dev-api.climingo.xyz \
  -d api.climingo.xyz \
  -d api-report.singco.de \
  -d api-chart.singco.de \
  --expand \
  --non-interactive \
  --agree-tos \
  --email spiderq10@gmail.com

echo "Copying certificates..."
sudo cp /etc/letsencrypt/live/dev-app.climingo.xyz/fullchain.pem ./ssl/letsencrypt-fullchain.pem
sudo cp /etc/letsencrypt/live/dev-app.climingo.xyz/privkey.pem ./ssl/letsencrypt-privkey.pem
sudo chmod 644 ./ssl/letsencrypt-fullchain.pem
sudo chmod 604 ./ssl/letsencrypt-privkey.pem

echo "Starting nginx container..."
docker-compose up -d

echo "Certificate issuance completed!"
