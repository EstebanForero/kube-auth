#!/usr/bin/env bash
set -euo pipefail

NS_CM="cert-manager"
NS_ZIT="auth"

# 1) Cloudflare DNS-01 token (ACME)
if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
  echo "Set CLOUDFLARE_API_TOKEN env var"
  exit 1
fi
kubectl create ns "$NS_CM" --dry-run=client -o yaml | kubectl apply -f -
kubectl -n "$NS_CM" create secret generic cloudflare-api-token-secret \
  --from-literal=api-token="$CLOUDFLARE_API_TOKEN" \
  --dry-run=client -o yaml | kubectl apply -f -

# 2) Zitadel masterkey (32 random chars)
kubectl create ns "$NS_ZIT" --dry-run=client -o yaml | kubectl apply -f -
kubectl -n "$NS_ZIT" create secret generic zitadel-masterkey \
  --from-literal=masterkey="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32)" \
  --dry-run=client -o yaml | kubectl apply -f -

# 3) Internal TLS for Zitadel (HTTPS upstream)
CN="zitadel.${NS_ZIT}.svc"
SAN1="DNS:zitadel.${NS_ZIT}.svc"
SAN2="DNS:zitadel.${NS_ZIT}.svc.cluster.local"
openssl req -newkey rsa:2048 -nodes -keyout internal.key -subj "/CN=${CN}" -out internal.csr
cat > san.cnf <<EOF
subjectAltName=${SAN1},${SAN2}
EOF
openssl x509 -req -in internal.csr -signkey internal.key -days 397 -extfile san.cnf -out internal.crt
kubectl -n "$NS_ZIT" create secret tls zitadel-internal-tls \
  --cert=internal.crt --key=internal.key \
  --dry-run=client -o yaml | kubectl apply -f -
rm -f internal.key internal.csr internal.crt san.cnf

echo "Secrets created."

