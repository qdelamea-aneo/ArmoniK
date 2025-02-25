export ARMONIK_SUFFIX?=main
export ARMONIK_REGION?=eu-west-3
export ARMONIK_PROFILE?=default
export ARMONIK_BUCKET_NAME?=armonik-tfstate
export ARMONIK_KUBERNETES_NAMESPACE?=armonik
export KEDA_KUBERNETES_NAMESPACE?=default
export METRICS_SERVER_KUBERNETES_NAMESPACE?=kube-system
export TFSTATE_BUCKET_NAME=$(ARMONIK_BUCKET_NAME)-$(ARMONIK_SUFFIX)
export PUBLIC_VPC?=true
export PUBLIC_ACCESS_EKS?=true

CURRENT_DIR=$(shell pwd)
VPC_PARAMETERS_FILE?=$(CURRENT_DIR)/vpc/generated/vpc-output.json
STORAGE_PARAMETERS_FILE?=$(CURRENT_DIR)/storage/generated/storage-output.json
MONITORING_PARAMETERS_FILE?=$(CURRENT_DIR)/monitoring/generated/monitoring-output.json
EKS_PARAMETERS_FILE?=$(CURRENT_DIR)/eks/generated/eks-output.json
KUBECONFIG?=$(CURRENT_DIR)/eks/generated/kubeconfig
GENERATED_DIR=$(CURRENT_DIR)/generated
MODULES_DIR=$(GENERATED_DIR)/infra-modules
VERSIONS_FILE?=$(shell realpath ../../../versions.tfvars.json)

####################################
# KSM and S3 buckets for TF states #
####################################

deploy-s3-of-backend:
	$(MAKE) -C $(CURRENT_DIR)/backend deploy \
		SUFFIX=$(ARMONIK_SUFFIX) \
		REGION=$(ARMONIK_REGION) \
		BUCKET_NAME=$(ARMONIK_BUCKET_NAME) \
		PROFILE=$(ARMONIK_PROFILE)

destroy-s3-of-backend:
	$(MAKE) -C $(CURRENT_DIR)/backend destroy \
		SUFFIX=$(ARMONIK_SUFFIX) \
		REGION=$(ARMONIK_REGION) \
		BUCKET_NAME=$(ARMONIK_BUCKET_NAME) \
		PROFILE=$(ARMONIK_PROFILE)

####################################
#             AWS VPC              #
####################################

deploy-vpc:
	$(MAKE) -C $(CURRENT_DIR)/vpc deploy \
		SUFFIX=$(ARMONIK_SUFFIX) \
		REGION=$(ARMONIK_REGION) \
		PROFILE=$(ARMONIK_PROFILE) \
		TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
		PUBLIC_VPC=$(PUBLIC_VPC) \
		MODULES_DIR=$(MODULES_DIR) \
		VERSIONS_FILE=$(VERSIONS_FILE)

destroy-vpc:
	$(MAKE) -C $(CURRENT_DIR)/vpc destroy \
		SUFFIX=$(ARMONIK_SUFFIX) \
		REGION=$(ARMONIK_REGION) \
		PROFILE=$(ARMONIK_PROFILE) \
		TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
		PUBLIC_VPC=$(PUBLIC_VPC) \
		MODULES_DIR=$(MODULES_DIR) \
		VERSIONS_FILE=$(VERSIONS_FILE)

clean-vpc:
	$(MAKE) -C $(CURRENT_DIR)/vpc clean

####################################
#            AWS ECR               #
####################################

deploy-ecr:
	$(MAKE) -C $(CURRENT_DIR)/ecr deploy \
		SUFFIX=$(ARMONIK_SUFFIX) \
		REGION=$(ARMONIK_REGION) \
		PROFILE=$(ARMONIK_PROFILE) \
		TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
		MODULES_DIR=$(MODULES_DIR) \
		VERSIONS_FILE=$(VERSIONS_FILE)

destroy-ecr:
	$(MAKE) -C $(CURRENT_DIR)/ecr destroy \
		SUFFIX=$(ARMONIK_SUFFIX) \
		REGION=$(ARMONIK_REGION) \
		PROFILE=$(ARMONIK_PROFILE) \
		TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
		MODULES_DIR=$(MODULES_DIR) \
		VERSIONS_FILE=$(VERSIONS_FILE)

clean-ecr:
	$(MAKE) -C $(CURRENT_DIR)/ecr clean

####################################
#             AWS EKS              #
####################################

deploy-eks:
	$(MAKE) -C $(CURRENT_DIR)/eks deploy \
		SUFFIX=$(ARMONIK_SUFFIX) \
		REGION=$(ARMONIK_REGION) \
		PROFILE=$(ARMONIK_PROFILE) \
		VPC_PARAMETERS_FILE=$(VPC_PARAMETERS_FILE) \
		TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
		PUBLIC_ACCESS_EKS=$(PUBLIC_ACCESS_EKS) \
		KUBECONFIG=$(KUBECONFIG) \
		MODULES_DIR=$(MODULES_DIR) \
		VERSIONS_FILE=$(VERSIONS_FILE)

destroy-eks:
	$(MAKE) -C $(CURRENT_DIR)/eks destroy \
		SUFFIX=$(ARMONIK_SUFFIX) \
		REGION=$(ARMONIK_REGION) \
		PROFILE=$(ARMONIK_PROFILE) \
		VPC_PARAMETERS_FILE=$(VPC_PARAMETERS_FILE) \
		TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
		PUBLIC_ACCESS_EKS=$(PUBLIC_ACCESS_EKS) \
		KUBECONFIG=$(KUBECONFIG) \
		MODULES_DIR=$(MODULES_DIR) \
		VERSIONS_FILE=$(VERSIONS_FILE)

clean-eks:
	$(MAKE) -C $(CURRENT_DIR)/eks clean

####################################
#       Kubernetes namespace       #
####################################

create-namespace:
	@KEDA=$(shell kubectl --kubeconfig $(KUBECONFIG) get deploy -A -l app=keda-operator --no-headers=true -o name)
	@METRICS_SERVER=$(shell kubectl --kubeconfig $(KUBECONFIG) get deploy -A -l k8s-app=metrics-server --no-headers=true -o name)
	@kubectl --kubeconfig $(KUBECONFIG) get namespace $(ARMONIK_KUBERNETES_NAMESPACE)  > /dev/null 2>&1 && echo "namespace : '$(ARMONIK_KUBERNETES_NAMESPACE)' is already created." || kubectl --kubeconfig $(KUBECONFIG) create namespace $(ARMONIK_KUBERNETES_NAMESPACE)
	@kubectl --kubeconfig $(KUBECONFIG) get namespace $(KEDA_KUBERNETES_NAMESPACE)  > /dev/null 2>&1 && echo "namespace : '$(KEDA_KUBERNETES_NAMESPACE)' is already created." || kubectl --kubeconfig $(KUBECONFIG) create namespace $(KEDA_KUBERNETES_NAMESPACE)
	@kubectl --kubeconfig $(KUBECONFIG) get namespace $(METRICS_SERVER_KUBERNETES_NAMESPACE)  > /dev/null 2>&1 &&  echo "namespace : '$(METRICS_SERVER_KUBERNETES_NAMESPACE)' is already created." || kubectl --kubeconfig $(KUBECONFIG) create namespace $(METRICS_SERVER_KUBERNETES_NAMESPACE)

delete-namespace:
	kubectl --kubeconfig $(KUBECONFIG) delete namespace $(ARMONIK_KUBERNETES_NAMESPACE) || true
	kubectl --kubeconfig $(KUBECONFIG) delete namespace $(KEDA_KUBERNETES_NAMESPACE) || true
	kubectl --kubeconfig $(KUBECONFIG) delete namespace $(METRICS_SERVER_KUBERNETES_NAMESPACE) || true

####################################
#              KEDA                #
####################################

deploy-keda:
	@if [ "${KEDA}" = "" ]; then\
        $(MAKE) -C $(CURRENT_DIR)/keda deploy \
        	NAMESPACE=$(KEDA_KUBERNETES_NAMESPACE) \
        	SUFFIX=$(ARMONIK_SUFFIX) \
        	REGION=$(ARMONIK_REGION) \
        	PROFILE=$(ARMONIK_PROFILE) \
        	KUBECONFIG=$(KUBECONFIG) \
        	TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
        	MODULES_DIR=$(MODULES_DIR) \
        	VERSIONS_FILE=$(VERSIONS_FILE);\
    fi

destroy-keda:
	$(MAKE) -C $(CURRENT_DIR)/keda destroy \
		NAMESPACE=$(KEDA_KUBERNETES_NAMESPACE) \
		SUFFIX=$(ARMONIK_SUFFIX) \
		REGION=$(ARMONIK_REGION) \
		PROFILE=$(ARMONIK_PROFILE) \
		KUBECONFIG=$(KUBECONFIG) \
		TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
		MODULES_DIR=$(MODULES_DIR) \
		VERSIONS_FILE=$(VERSIONS_FILE)

clean-keda:
	$(MAKE) -C $(CURRENT_DIR)/keda clean

####################################
#         Metrics server           #
####################################

deploy-metrics-server:
	$(MAKE) -C $(CURRENT_DIR)/metrics-server deploy \
		NAMESPACE=$(METRICS_SERVER_KUBERNETES_NAMESPACE) \
		SUFFIX=$(ARMONIK_SUFFIX) \
		REGION=$(ARMONIK_REGION) \
		PROFILE=$(ARMONIK_PROFILE) \
		KUBECONFIG=$(KUBECONFIG) \
		TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
		MODULES_DIR=$(MODULES_DIR) \
		VERSIONS_FILE=$(VERSIONS_FILE)

destroy-metrics-server:
	$(MAKE) -C $(CURRENT_DIR)/metrics-server destroy \
		NAMESPACE=$(METRICS_SERVER_KUBERNETES_NAMESPACE) \
		SUFFIX=$(ARMONIK_SUFFIX) \
		REGION=$(ARMONIK_REGION) \
		PROFILE=$(ARMONIK_PROFILE) \
		KUBECONFIG=$(KUBECONFIG) \
		TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
		MODULES_DIR=$(MODULES_DIR) \
		VERSIONS_FILE=$(VERSIONS_FILE)

clean-metrics-server:
	$(MAKE) -C $(CURRENT_DIR)/metrics-server clean

####################################
#           AWS Storage            #
####################################

deploy-storage:
	$(MAKE) -C $(CURRENT_DIR)/storage deploy \
		SUFFIX=$(ARMONIK_SUFFIX) \
		REGION=$(ARMONIK_REGION) \
		PROFILE=$(ARMONIK_PROFILE) \
		KUBECONFIG=$(KUBECONFIG) \
		NAMESPACE=$(ARMONIK_KUBERNETES_NAMESPACE) \
		VPC_PARAMETERS_FILE=$(VPC_PARAMETERS_FILE) \
		EKS_PARAMETERS_FILE=$(EKS_PARAMETERS_FILE) \
		TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
		MODULES_DIR=$(MODULES_DIR) \
		VERSIONS_FILE=$(VERSIONS_FILE)

destroy-storage:
	$(MAKE) -C $(CURRENT_DIR)/storage destroy \
		SUFFIX=$(ARMONIK_SUFFIX) \
		REGION=$(ARMONIK_REGION) \
		PROFILE=$(ARMONIK_PROFILE) \
		KUBECONFIG=$(KUBECONFIG) \
		NAMESPACE=$(ARMONIK_KUBERNETES_NAMESPACE) \
		VPC_PARAMETERS_FILE=$(VPC_PARAMETERS_FILE) \
		EKS_PARAMETERS_FILE=$(EKS_PARAMETERS_FILE) \
		TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
		MODULES_DIR=$(MODULES_DIR) \
		VERSIONS_FILE=$(VERSIONS_FILE)

clean-storage:
	$(MAKE) -C $(CURRENT_DIR)/storage clean

####################################
#           Monitoring             #
####################################

deploy-monitoring:
	$(MAKE) -C $(CURRENT_DIR)/monitoring deploy \
		SUFFIX=$(ARMONIK_SUFFIX) \
		REGION=$(ARMONIK_REGION) \
		PROFILE=$(ARMONIK_PROFILE) \
		KUBECONFIG=$(KUBECONFIG) \
		NAMESPACE=$(ARMONIK_KUBERNETES_NAMESPACE) \
		STORAGE_PARAMETERS_FILE=$(STORAGE_PARAMETERS_FILE) \
		EKS_PARAMETERS_FILE=$(EKS_PARAMETERS_FILE) \
		TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
		MODULES_DIR=$(MODULES_DIR) \
		VERSIONS_FILE=$(VERSIONS_FILE)

destroy-monitoring:
	$(MAKE) -C $(CURRENT_DIR)/monitoring destroy \
		SUFFIX=$(ARMONIK_SUFFIX) \
		REGION=$(ARMONIK_REGION) \
		PROFILE=$(ARMONIK_PROFILE) \
		KUBECONFIG=$(KUBECONFIG) \
		NAMESPACE=$(ARMONIK_KUBERNETES_NAMESPACE) \
		STORAGE_PARAMETERS_FILE=$(STORAGE_PARAMETERS_FILE) \
		EKS_PARAMETERS_FILE=$(EKS_PARAMETERS_FILE) \
		TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
		MODULES_DIR=$(MODULES_DIR) \
		VERSIONS_FILE=$(VERSIONS_FILE)

clean-monitoring:
	$(MAKE) -C $(CURRENT_DIR)/monitoring clean

####################################
#             ArmoniK              #
####################################

deploy-armonik:
	$(MAKE) -C $(CURRENT_DIR)/armonik deploy \
		REGION=$(ARMONIK_REGION) \
		PROFILE=$(ARMONIK_PROFILE) \
		KUBECONFIG=$(KUBECONFIG) \
		NAMESPACE=$(ARMONIK_KUBERNETES_NAMESPACE) \
		STORAGE_PARAMETERS_FILE=$(STORAGE_PARAMETERS_FILE) \
		MONITORING_PARAMETERS_FILE=$(MONITORING_PARAMETERS_FILE) \
		TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
		MODULES_DIR=$(MODULES_DIR) \
		VERSIONS_FILE=$(VERSIONS_FILE)

destroy-armonik:
	$(MAKE) -C $(CURRENT_DIR)/armonik destroy \
		REGION=$(ARMONIK_REGION) \
		PROFILE=$(ARMONIK_PROFILE) \
		KUBECONFIG=$(KUBECONFIG) \
		NAMESPACE=$(ARMONIK_KUBERNETES_NAMESPACE) \
		STORAGE_PARAMETERS_FILE=$(STORAGE_PARAMETERS_FILE) \
		MONITORING_PARAMETERS_FILE=$(MONITORING_PARAMETERS_FILE) \
		TFSTATE_BUCKET_NAME=$(TFSTATE_BUCKET_NAME) \
		MODULES_DIR=$(MODULES_DIR) \
		VERSIONS_FILE=$(VERSIONS_FILE)

clean-armonik:
	$(MAKE) -C $(CURRENT_DIR)/armonik clean

####################################
#          KUBECONFIG              #
####################################

kubeconfig:
	@echo "Execute the following commands:"
	@echo "------------------------------"
	@echo "export KUBECONFIG=$(shell cat $(EKS_PARAMETERS_FILE) | jq -r '.eks.kubeconfig_file')"

####################################
#             Modules              #
####################################

clean-modules:
	@rm -rf $(GENERATED_DIR)

####################################
#               All                #
####################################

deploy-all: deploy-vpc deploy-ecr deploy-eks create-namespace deploy-keda deploy-metrics-server deploy-storage deploy-monitoring deploy-armonik kubeconfig

destroy-all: destroy-armonik destroy-monitoring destroy-storage destroy-metrics-server destroy-keda delete-namespace destroy-eks destroy-ecr destroy-vpc

clean-all: clean-armonik clean-monitoring clean-storage clean-metrics-server clean-keda clean-eks clean-ecr clean-vpc clean-modules
