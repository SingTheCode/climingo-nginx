# SSL 인증서 설정 계획 - api.climingo.xyz

## 현재 상태

### 완료된 도메인
- ✅ `dev-app.climingo.xyz` - Let's Encrypt 인증서 적용 완료
- ✅ `dev-api.climingo.xyz` - Let's Encrypt 인증서 적용 완료

### 대기 중인 도메인
- ⏳ `api.climingo.xyz` - DNS 변경 후 인증서 발급 예정

## DNS 변경 계획

### 변경 전
```
api.climingo.xyz → AWS (13.124.15.68, 3.35.252.131)
```

### 변경 후
```
api.climingo.xyz → climingo.hopto.org (182.220.64.71)
```

## 인증서 발급 절차

### 1. DNS 변경 확인
```bash
# DNS 전파 확인 (최대 24-48시간 소요 가능)
nslookup api.climingo.xyz

# 182.220.64.71 또는 climingo.hopto.org를 가리키는지 확인
```

### 2. Nginx 컨테이너 중지
```bash
cd /Users/singco/dev/climingo/nginx
docker-compose down
```

### 3. Let's Encrypt 인증서 발급
```bash
# 3개 도메인 모두 포함하여 재발급
sudo certbot certonly --standalone \
  -d dev-app.climingo.xyz \
  -d dev-api.climingo.xyz \
  -d api.climingo.xyz \
  --non-interactive \
  --agree-tos \
  --email admin@climingo.xyz
```

### 4. 인증서 파일 복사
```bash
cd /Users/singco/dev/climingo/nginx

# 새로 발급된 인증서 복사
sudo cp /etc/letsencrypt/live/dev-app.climingo.xyz/fullchain.pem ./ssl/letsencrypt-fullchain.pem
sudo cp /etc/letsencrypt/live/dev-app.climingo.xyz/privkey.pem ./ssl/letsencrypt-privkey.pem
sudo chmod 644 ./ssl/letsencrypt-fullchain.pem
sudo chmod 644 ./ssl/letsencrypt-privkey.pem
```

### 5. nginx.conf 수정

`api.climingo.xyz` 서버 블록을 Let's Encrypt 인증서로 변경:

```nginx
# api.climingo.xyz -> 운영 API 서버
server {
    listen 80;
    server_name api.climingo.xyz;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.climingo.xyz;

    ssl_certificate /etc/nginx/ssl/letsencrypt-fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/letsencrypt-privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        set $upstream climingo-api:8080;
        proxy_pass http://$upstream;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 6. Nginx 컨테이너 재시작
```bash
cd /Users/singco/dev/climingo/nginx
docker-compose up -d

# 상태 확인
docker ps | grep climingo-nginx
docker logs climingo-nginx
```

### 7. 인증서 확인
```bash
# 브라우저에서 확인
# https://api.climingo.xyz

# 또는 명령어로 확인
openssl s_client -connect api.climingo.xyz:443 -servername api.climingo.xyz < /dev/null 2>/dev/null | openssl x509 -noout -dates -issuer
```

## 자동 갱신 설정

### renew-cert.sh 스크립트 업데이트

기존 스크립트에 3개 도메인 모두 포함:

```bash
#!/bin/bash

# Let's Encrypt 인증서 갱신 스크립트

echo "Stopping nginx container..."
cd /Users/singco/dev/climingo/nginx
docker-compose down

echo "Renewing certificate..."
sudo certbot renew --standalone

echo "Copying certificates..."
sudo cp /etc/letsencrypt/live/dev-app.climingo.xyz/fullchain.pem ./ssl/letsencrypt-fullchain.pem
sudo cp /etc/letsencrypt/live/dev-app.climingo.xyz/privkey.pem ./ssl/letsencrypt-privkey.pem
sudo chmod 644 ./ssl/letsencrypt-fullchain.pem
sudo chmod 644 ./ssl/letsencrypt-privkey.pem

echo "Starting nginx container..."
docker-compose up -d

echo "Certificate renewal completed!"
echo "Renewed at: $(date)" >> /Users/singco/dev/climingo/nginx/logs/cert-renew.log
```

### crontab 설정

```bash
# crontab 편집
crontab -e

# 매월 1일 새벽 3시에 자동 갱신
0 3 1 * * /Users/singco/dev/climingo/nginx/renew-cert.sh >> /Users/singco/dev/climingo/nginx/logs/cert-renew.log 2>&1
```

### crontab 설정 확인
```bash
# 현재 crontab 확인
crontab -l

# 로그 확인
tail -f /Users/singco/dev/climingo/nginx/logs/cert-renew.log
```

## 체크리스트

### DNS 변경 후
- [ ] DNS 전파 확인 (`nslookup api.climingo.xyz`)
- [ ] Nginx 컨테이너 중지
- [ ] 3개 도메인 인증서 재발급
- [ ] 인증서 파일 복사 및 권한 설정
- [ ] nginx.conf 수정 (api.climingo.xyz 블록)
- [ ] Nginx 컨테이너 재시작
- [ ] 브라우저에서 인증서 확인

### 자동 갱신 설정
- [ ] renew-cert.sh 스크립트 확인
- [ ] crontab 설정 추가
- [ ] crontab 설정 확인
- [ ] 로그 디렉토리 생성 확인

## 주의사항

1. **DNS 전파 시간**: DNS 변경 후 최대 24-48시간 소요 가능
2. **인증서 만료**: 90일마다 갱신 필요 (자동 갱신 설정 필수)
3. **다운타임**: 인증서 발급 시 Nginx 컨테이너 중지 필요 (약 1-2분)
4. **백업**: 기존 자체 서명 인증서 파일 보관 (`cert.pem`, `key.pem`)

## 예상 소요 시간

- DNS 변경: 즉시 (전파는 최대 48시간)
- 인증서 발급: 1-2분
- 설정 변경: 5분
- 테스트 및 확인: 5분

**총 예상 시간**: 약 15분 (DNS 전파 시간 제외)
