# Cloud infrastructure terraform stack

# Prerequisites
* access to Azure subscription with sufficient permissions
* terraform >=1.2.9 <1.3 [GitHub issue](https://github.com/hashicorp/terraform/issues/32146)
* azure-cli
* operating user with permissions

# Getting Started
Due to security restrictions it is assumed that resource group is created in advance and imported into the state.
## Azure
Login to Azure:
```
az login
```
If needed select a subscription:
```
az account set --subscription 614a7505-7e5f-4380-8524-847e54dd45dd
```

## Terraform
Terraform stack is located in `tf` directory.

Initialize:
```
terraform init -var-file=env/poc/env.tfvars
terraform import azurerm_resource_group.rg \
  /subscriptions/614a7505-7e5f-4380-8524-847e54dd45dd/resourceGroups/RG-EUR-WW-POC-MP
```
Plan:
```
terraform plan -var-file=env/poc/env.tfvars -out=test.tfplan
```
Apply:
```
terraform apply -input=false -auto-approve test.tfplan
```