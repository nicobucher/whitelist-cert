#!/bin/bash


SERVERNAME=$(echo "$1" | sed -E -e 's/https?:\/\///' -e 's/\/.*//')
shift

PORT=443
USERNAME=$USER

while getopts ':p:u:' opt; do
    case $opt in
        p)  
	    PORT="$OPTARG"
            ;;
        u)  
            USERNAME="$OPTARG" 
            ;;
        *)  
            exit 1   
            ;;
    esac
done

echo "$SERVERNAME:$PORT, $USERNAME"

if [[ "$SERVERNAME" =~ ^([\da-z\.-]+\.[a-z\.]{2,6}|[\d\.]+)([\/:?=&#]{1}[\da-z\.-]+)*[\/\?]?$ ]]; then
    echo "Adding certificate for $SERVERNAME"
    echo -n | openssl s_client -connect $SERVERNAME:$PORT | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | tee $SERVERNAME.crt
    sudo mv $SERVERNAME.crt /usr/share/ca-certificates/
    sudo update-ca-certificates
    sudo certutil -d sql:/home/$USERNAME/.pki/nssdb -A -t "CP,CP," -n "$SERVERNAME" -i /usr/share/ca-certificates/$SERVERNAME.crt
    sudo certutil -d sql:/home/$USERNAME/.pki/nssdb -L
else
    echo "Use this script to whitelist ssl ca-certificates of web pages."
    echo ""
    echo "Usage: $0 www.site.name -p [port] -u [username]"
    echo "Use [port] to specify ports other than 443"
    echo "Use [username] to specify if you want to whitelist the certificate for other users"
    echo "http:// and such will be stripped automatically"
    echo ""
    echo "Use: certutil -d sql:/home/$USERNAME/.pki/nssdb -D -n $certnickname to remove certificates
    echo "Use: certutil -d sql:/home/$USERNAME/.pki/nssdb -L to list all certificates in the database"
fi
