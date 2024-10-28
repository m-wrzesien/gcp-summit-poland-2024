#!/bin/bash

DOCKER_REGISTRY=europe-docker.pkg.dev/$PROJECT/docker-repo

echo "Removing istio and network policies.."
kubectl delete -f apps/k8s/istio
kubectl delete -f apps/k8s/network-policies

echo "Uninstalling istio charts.."

for chart in $(helm list -n istio-system --no-headers | awk '{print $1}'); do
    helm uninstall -n istio-system "$chart"
done

echo "Removing app deployments..."

for ns in "backend" "frontend" "default"; do
    for dp in $(kubectl get deployments -n "$ns" --no-headers | awk '{print $1}'); do
        kubectl delete deployment -n "$ns" "$dp"
    done
done

echo "Removing images from registry..."

for image in $(gcloud artifacts docker images list "$DOCKER_REGISTRY" | tail -n +2 | awk '{printf "%s@%s\n", $1, $2}'); do
    gcloud artifacts docker images delete "$image" --delete-tags --quiet
done

echo "Destroying bin auth policy"
cd binary-authorization
terraform destroy -target google_binary_authorization_policy.policy -var "project_id=${PROJECT}"
cd -