#!/usr/bin/env bash
set -euo pipefail
helm dependency build
helm upgrade --install kube-auth . -f values.yaml

