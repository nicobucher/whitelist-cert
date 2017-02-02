#!/bin/bash

SERVERNAME=$(echo "$1" | sed -E -e 's/https?:\/\///' -e 's/\/.*//')
echo "$SERVERNAME"

if [[ "$SERVERNAME" =~ .*\..* ]]; then
    echo "Adding certificate for $SERVERNAME"
    if [[ $# -eq 2 ]]; then
        echo -n | openssl s_client -connect $SERVERNAME:$2 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | tee $SERVERNAME.crt
    else
	echo -n | openssl s_client -connect $SERVERNAME:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | tee $SERVERNAME.crt
    fi
    sudo mv $SERVERNAME.crt /usr/share/ca-certificates/
    sudo update-ca-certificates
    certutil -d sql:$HOME/.pki/nssdb -A -t "CP,CP," -n "$SERVERNAME" -i /usr/share/ca-certificates/$SERVERNAME.crt
else
    echo "Use this script to whitelist ssl ca-certificates of web pages."
    echo ""
    echo "Usage: $0 www.site.name [port]"
    echo "http:// and such will be stripped automatically"
fi
