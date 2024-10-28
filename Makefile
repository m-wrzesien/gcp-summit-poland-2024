.PHONY: attest-image build-images clear deploy-app deploy-bin-auth deploy-istio-obj deploy-net-pol install-istio terraform-apply

export PROJECT=esky-gcp-summit-warsaw-2024

attest-image:
	./attest.sh $(filter-out $@,$(MAKECMDGOALS))

build-images:
	./build-images.sh

clear:
	./clear.sh

deploy-app:
	./deploy-k8s.sh app

deploy-bin-auth:
	cd binary-authorization && \
	terraform apply -var "project_id=$(PROJECT)"

deploy-istio-obj:
	./deploy-k8s.sh istio

deploy-net-pol:
	./deploy-k8s.sh np

install-istio:
	./install-istio.sh

terraform-apply:
	cd terraform && \
	terraform apply -var "project_id=$(PROJECT)"