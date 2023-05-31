# Azure Container Apps Album

This example shows how to deploy 2 components: frontend and backend and set connection between them in a container app environment.

This repository is a companion for the [Azure Container Apps code-to-cloud quickstart](https://docs.microsoft.com/en-us/azure/container-apps/quickstart-code-to-cloud?tabs=bash%2Ccsharp&pivots=acr-remote).

Additional aspects of Container Apps are part of the example:
* building container images in ACR
* custom VNET integration
* internal and external ingresses
* IP based access restrictions
* running tests automated tests


# Infrastructure

Required infrastructure is created using terraform in Azure Cloud. The terraform stack is provided in `tf/` directory. As an example which is not intended for long time retention and maintenance it is set to run with a local state file.

# ADO pipeline
Container App deployment is automated using Azure DevOps pipeline provided in `devips/ado/` directory. The pipeline requires the infrastructure to be built previously to its execution. It also requires a service connection with sufficient permissions