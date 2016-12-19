#!/bin/bash

if [ -z "$SECRET_NAME" ]; then
    echo "ERROR: Secret name is empty or unset"
    exit 1
fi

PKI_DIR=/etc/openvpn/pki

KEY=$(cat $PKI_DIR/private/${EASYRSA_REQ_CN}.key | base64 --wrap=0)
CA=$(cat $PKI_DIR/ca.crt | base64 --wrap=0)
CERT=$(cat $PKI_DIR/issued/${EASYRSA_REQ_CN}.crt | base64 --wrap=0)
DH=$(cat $PKI_DIR/dh.pem | base64 --wrap=0)
TLS_AUTH=$(cat $PKI_DIR/ta.key | base64 --wrap=0)

NAMESPACE=${NAMESPACE:-default}
TYPE=${TYPE:-Opaque}

kubectl get secrets --namespace $NAMESPACE $SECRET_NAME && ACTION=replace || ACTION=create;

cat << EOF | kubectl $ACTION -f -
{
 "apiVersion": "v1",
 "kind": "Secret",
 "metadata": {
   "name": "$SECRET_NAME",
   "namespace": "$NAMESPACE"
 },
 "data": {
   "key": "$KEY",
   "ca": "$CA",
   "cert": "$CERT",
   "dh": "$DH",
   "tls_auth": "$TLS_AUTH"
 },
 "type": "$TYPE"
}
EOF