#!/usr/bin/env bash
set -euo pipefail
NS="argocd"
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n "$NS" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n "$NS" rollout status deploy/argocd-server --timeout=300s
echo "Argo CD admin password:"
kubectl -n "$NS" get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
echo "Port-forward: kubectl -n $NS port-forward svc/argocd-server 8080:443"

