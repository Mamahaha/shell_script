#!/bin/sh


case "$1" in
  "e" )
    echo "Encrypt a string"
    echo $2 | openssl aes-256-cbc -e -base64 -k $3;;
  "d" )
    echo "Decrypt a string"
    echo $2 | openssl aes-256-cbc -d -base64 -k $3;;
  * )
    echo "This script is used to encrypt/decrypt a string"
    echo "Please DO remember clean all operation record after you run the script";;
esac

