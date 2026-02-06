#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/Users/singco/dev/climingo/nginx"
SSL_DIR="${PROJECT_DIR}/ssl"
CERT_NAME="climingo"   # <- 본인 cert-name으로 수정 (certbot certificates로 확인)
COMPOSE="docker-compose"

sudo certbot renew --standalone --cert-name "${CERT_NAME}" \
  --pre-hook "cd ${PROJECT_DIR} && ${COMPOSE} down && sleep 2" \
  --deploy-hook "mkdir -p ${SSL_DIR} \
    && cp /etc/letsencrypt/live/${CERT_NAME}/fullchain.pem ${SSL_DIR}/letsencrypt-fullchain.pem \
    && cp /etc/letsencrypt/live/${CERT_NAME}/privkey.pem   ${SSL_DIR}/letsencrypt-privkey.pem \
    && chmod 644 ${SSL_DIR}/letsencrypt-fullchain.pem \
    && chmod 640 ${SSL_DIR}/letsencrypt-privkey.pem" \
  --post-hook "cd ${PROJECT_DIR} && ${COMPOSE} up -d"

echo "Certificate renew script finished."
