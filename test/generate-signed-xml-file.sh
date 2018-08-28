#!/usr/bin/env bash
openssl req -x509 -newkey rsa:1024 -keyout key.pem -passout pass:test -out cert.pem -days 365 -subj '/CN=localhost'
openssl pkcs12 -export -out key.p12 -inkey key.pem -in cert.pem -passin pass:test -passout pass:test
xmlsec1 --sign --output test-signed.xml --pkcs12 key.p12 --pwd test --trusted-pem cert.pem --insecure test.xml
