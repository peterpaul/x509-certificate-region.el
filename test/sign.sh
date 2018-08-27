#!/usr/bin/env bash
openssl pkcs12 -export -out key.p12 -inkey key.pem -in cert.pem
xmlsec1 --sign --output test-signed.xml --pkcs12 key.p12 --pwd test --trusted-pem cert.pem --insecure test.xml
