# Google Cloud Summit Poland 2024

`How to secure GKE when handling customers payments data?`

This repo contains all code required for the presentiation including:
* A Terraform manifests for deploying:
* * cluster (directory `terraform`)
* * binary-authorization related objects (directory `binary-authorization`)
* Source code for app and it's k8s manifests (directory `apps`) for:
* * deployments
* * network policies
* * istio objects (authorization policies)
* Istio helm charts (directory `istio`)
* Scripts and Makefile for automation

## Deployment
### Required software:
* docker
* gcloud
* helm
* kubectl
* terraform
### Steps to deploy:
1. Change variable `PROJECT` in `Makefile` and `attest.sh`
1. Deploy K8S cluster using `make terraform-apply`
1. Download credentials to clusters by executing for each:
    ```
    gcloud container clusters get-credentials  --project [PROJECT] --zone [ZONE] [CLUSTER_NAME]
    ```
1. Build images with `make build-images`
1. Deploy binary authorization objects with `make deploy-bin-auth`
1. Attest images for secure images generated on step 4 with `./attest.sh <IMAGE>`
1. Deploy apps with `make deploy-app`
1. Deploy network policies executing `make deploy-net-pol`
1. Install istio crd and istiod by `make install-istio`
1. Deploy istio object by executing `make deploy-istio-obj`