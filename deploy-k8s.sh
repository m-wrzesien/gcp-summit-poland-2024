#!/bin/bash
set -euo pipefail

diffAndDeploy() {
    file=$1
    kubectl diff -f "$file" || true

    echo "Do you want to continue?"
    read -rn 1

    kubectl apply -f "$file"
}

deployApp() {
    cd apps/k8s
    diffAndDeploy backend.yaml
    diffAndDeploy frontend.yaml
    diffAndDeploy i-wont-deploy.yaml
    kubectl get service -n frontend
}

deployNetworkPolicies() {
    cd apps/k8s/network-policies
    diffAndDeploy 0-deny_all.yaml
    diffAndDeploy 1-allow_dns.yaml
    diffAndDeploy 2-allow_ingress.yaml
    diffAndDeploy 3-allow_from_frontend_to_backend_ns.yaml
    diffAndDeploy 4-allow_egress_outside.yaml
}

deployIstioObjects() {
    kubectl rollout restart deployment nginx -n frontend
    kubectl rollout status deployment nginx -n frontend
    cd apps/k8s/istio
    diffAndDeploy 0-www_esky_pl.yaml
    diffAndDeploy 1-cloud_google_com.yaml
}

set -x

case $1 in
    app)
       deployApp;;
    np)
       deployNetworkPolicies;;
    istio)
       deployIstioObjects;;
    *)
        echo "Incorrect selection"
        exit 1;;
esac