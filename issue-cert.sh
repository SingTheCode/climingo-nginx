#!/bin/bash

# Let's Encrypt 인증서 발급 스크립트

echo "Stopping nginx container..."
docker-compose down

echo "Issuing certificate for climingo.xyz domains..."
sudo certbot certonly --standalone \
  -d dev-app.climingo.xyz \
  -d dev-api.climingo.xyz \
  -d api.climingo.xyz \
  --expand \
  --non-interactive \
  --agree-tos \
  --email spiderq10@gmail.com

echo "Copying climingo.xyz certificates..."
sudo cp /etc/letsencrypt/live/dev-app.climingo.xyz/fullchain.pem ./ssl/letsencrypt-fullchain.pem
sudo cp /etc/letsencrypt/live/dev-app.climingo.xyz/privkey.pem ./ssl/letsencrypt-privkey.pem
sudo chmod 644 ./ssl/letsencrypt-fullchain.pem
sudo chmod 604 ./ssl/letsencrypt-privkey.pem

echo "Issuing certificate for api-report.singco.de..."
sudo certbot certonly --standalone \
  -d api-report.singco.de \
  --non-interactive \
  --agree-tos \
  --email spiderq10@gmail.com

echo "Copying singco.de certificates..."
sudo cp /etc/letsencrypt/live/api-report.singco.de/fullchain.pem ./ssl/singco-fullchain.pem
sudo cp /etc/letsencrypt/live/api-report.singco.de/privkey.pem ./ssl/singco-privkey.pem
sudo chmod 644 ./ssl/singco-fullchain.pem
sudo chmod 604 ./ssl/singco-privkey.pem

echo "Issuing certificate for api-chart.singco.de..."
sudo certbot certonly --standalone \
  -d api-chart.singco.de \
  --non-interactive \
  --agree-tos \
  --email spiderq10@gmail.com

echo "Copying singco.de certificates..."
sudo cp /etc/letsencrypt/live/api-chart.singco.de/fullchain.pem ./ssl/singco-de-fullchain.pem
sudo cp /etc/letsencrypt/live/api-chart.singco.de/privkey.pem ./ssl/singco-de-privkey.pem
sudo chmod 644 ./ssl/singco-de-fullchain.pem
sudo chmod 604 ./ssl/singco-de-privkey.pem

echo "Starting nginx container..."
docker-compose up -d

echo "Certificate issuance completed!"
