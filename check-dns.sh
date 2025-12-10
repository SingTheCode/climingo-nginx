#!/bin/bash

# DNS 전파 확인 스크립트

echo "Checking DNS for api.climingo.xyz..."
nslookup api.climingo.xyz

echo ""
echo "Expected IP: 182.220.64.71"
echo "Current resolution:"
dig +short api.climingo.xyz
