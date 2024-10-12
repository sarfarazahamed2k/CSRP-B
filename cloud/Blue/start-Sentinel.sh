#!/bin/bash

az provider register --namespace Microsoft.OperationalInsights

az monitor log-analytics workspace create -g HR-Department -n HR-Department-workspace


# az sentinel setting create --name "EyesOn" --resource-group HR-Department --workspace-name HR-Department-workspace


az monitor log-analytics workspace create -g WebApp -n WebApp-workspace


# az sentinel setting create --name "EyesOn" --resource-group WebApp --workspace-name WebApp-workspace


az monitor log-analytics workspace create -g myRG1 -n myRG1-workspace


# az sentinel setting create --name "EyesOn" --resource-group myRG1 --workspace-name myRG1-workspace

# https://portal.azure.com/#browse/microsoft.securityinsightsarg%2Fsentinel - Create sentinel for all 3 resource groups