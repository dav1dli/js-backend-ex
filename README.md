# Azure Container Apps Album API

This is the companion repository for the [Azure Container Apps code-to-cloud quickstart](https://docs.microsoft.com/en-us/azure/container-apps/quickstart-code-to-cloud?tabs=bash%2Ccsharp&pivots=acr-remote).

# Infrastructure

Required infrastructure is created using terraform in Azure Cloud. The terraform stack is provided in `tf/` directory.

# ADO pipeline
Container App deployment is automated using Azure DevOps pipeline provided in `devips/ado/` directory. The pipeline requires the infrastructure to be built previously to its execution. It also requires a service connection with sufficient permissions