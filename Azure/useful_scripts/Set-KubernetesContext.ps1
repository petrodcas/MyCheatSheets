<#
    .SYNOPSIS
        Sets current cluster context in azure.
    
    .DESCRIPTION
        Gets credentials of an azure cluster through az-cli and use it as current cluster context.

    .EXAMPLE

        Set-KubernetesContext.ps1 -AKSName mysuperaks -ResourceGroupName awesomeazrg
#>
param(
    # Name of the AKS in azure
    [string]$AKSName,
    # Name of the RG where the AKS is located
    [string]$ResourceGroupName
)

# Include cluster as kubeconfig context
az aks get-credentials --resource-group $ResourceGroupName --name $AKSName --only-show-errors

# Converts file format
kubelogin convert-kubeconfig -l azurecli

# Swaps context
kubectl config use-context $AKSName