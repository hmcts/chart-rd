.DEFAULT_GOAL := all
CHART := rd
RELEASE := chart-${CHART}-release
NAMESPACE := rd
TEST := ${RELEASE}-test-service
ACR := hmctspublic
ACR_SUBSCRIPTION := DCD-CNP-DEV
AKS_RESOURCE_GROUP := cnp-aks-rg
AKS_CLUSTER := cnp-aks-cluster

setup:
	helm repo add ${ACR} https://${ACR}.azurecr.io/helm/v1/repo
	az aks get-credentials --resource-group ${AKS_RESOURCE_GROUP} --name ${AKS_CLUSTER} --subscription DCD-CNP-DEV
	helm dependency update ${CHART}

depUpdate:
	helm dependency update ${CHART}

clean:
	-helm delete --purge ${RELEASE}
	-kubectl delete pod ${TEST} -n ${NAMESPACE}

lint:
	helm lint ${CHART} -f ci-values.yaml

deploy:
	helm install ${CHART} --name ${RELEASE} --namespace ${NAMESPACE} -f ci-values.yaml --wait --timeout 600

upgrade:
	helm upgrade --install ${RELEASE} ${CHART}  --namespace ${NAMESPACE} -f ci-values.yaml --wait --timeout 600

test:
	helm test ${RELEASE}

all: setup clean lint deploy test

.PHONY: setup clean lint deploy test all