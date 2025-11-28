#!/bin/sh
mkdir -p certs

# Cert SSL autofirmado
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/selfsigned.key \
  -out certs/selfsigned.crt \
  -subj "/CN=localhost"

# Parámetros Diffie-Hellman
openssl dhparam -out certs/dhparam.pem 2048