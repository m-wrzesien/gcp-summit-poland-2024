#!/bin/bash
set -euo pipefail
set -x

cd istio/base
if helm list -A | grep istio-crd >/dev/null; then
    helm dependency update
    helm diff -C5 upgrade --install istio-crd . -n istio-system -f values.yaml
else
    echo "Chart is not installed"
fi

echo "Do you want to continue?"
read -rn 1

helm upgrade --install istio-crd . -n istio-system --create-namespace -f values.yaml

cd -
cd istio/istiod

if helm list -A | grep istiod >/dev/null; then
    helm dependency update
    helm diff -C5 upgrade --install istiod . -n istio-system -f values.yaml
else
    echo "Chart is not installed"
fi


echo "Do you want to continue?"
read -rn 1

helm upgrade --install istiod . -n istio-system -f values.yaml

cd -