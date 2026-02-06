set -euo pipefail

CERT_NAME="climingo"   # 원하는 고정 이름
EMAIL="spiderq10@gmail.com"
SSL_DIR="./ssl"

cleanup() {
  echo "Starting nginx container..."
  docker-compose up -d || true
}
trap cleanup EXIT

echo "Stopping nginx container..."
docker-compose down

echo "Issuing certificate..."
sudo certbot certonly --standalone \
  --cert-name "$CERT_NAME" \
  -d dev-app.climingo.xyz \
  -d dev-api.climingo.xyz \
  -d api.climingo.xyz \
  -d api-report.singco.de \
  -d api-chart.singco.de \
  --non-interactive \
  --agree-tos \
  --email "$EMAIL"

echo "Copying certificates..."
sudo mkdir -p "$SSL_DIR"
sudo cp "/etc/letsencrypt/live/${CERT_NAME}/fullchain.pem" "${SSL_DIR}/letsencrypt-fullchain.pem"
sudo cp "/etc/letsencrypt/live/${CERT_NAME}/privkey.pem"   "${SSL_DIR}/letsencrypt-privkey.pem"

# 권한은 'nginx 컨테이너가 읽을 수 있는 사용자/그룹'에 맞춰야 함
sudo chmod 640 "${SSL_DIR}/letsencrypt-fullchain.pem" "${SSL_DIR}/letsencrypt-privkey.pem"