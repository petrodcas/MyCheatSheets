# Creating Kubernetes Service Connection through ConfigFile and API request

Steps to create a Kubernetes Service Connection in azure devops through commands.

## Table of content

* **Creating Service Account in Kubernetes Cluster**
  * [Creating Service Account in Kubernetes Cluster](#creating-service-account-in-kubernetes-cluster)
  * [Deploying ClusterRoleBinding](#deploying-clusterrolebinding)
  * [Deploying Secret](#deploying-secret)
* **Getting needed data**
  * [Getting Control Plane URL](#getting-control-plane-url)
  * [Getting Secret Token from Cluster](#getting-secret-token-from-cluster)
* **Creating Service Connection through Devops API**
  * [Creating the Service Connection's Configfile](#creating-the-service-connections-configfile)
  * [Creating the Service Connection through API request](#creating-the-service-connection-through-api-request)

## Creating Service Account in Kubernetes Cluster

```pwsh
    az account set -s {subscription Name or ID}
    az aks get-credentials --resource-group {resource group name} --name {AKS name}
    kubectl create serviceaccount {service account name} -n {namespace name}
```

**Note:** These commands are required to log into the cluster through **PIPELINE**.

```pwsh
    # Convert kubeconfig to a valid format
    kubelogin convert-kubeconfig -l azurecli

    # Set context in kubeconfig file
    kubectl config set-context $(aks_name)

    # Swap context
    kubectl config use-context $(aks_name)
```

## Deploying ClusterRoleBinding

Create the file:

```yaml
#Create ClusterRoleBindingapiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {service account name}-sa
  namespace: kube-system
subjects:
- kind: ServiceAccount
  name: {service account name}
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

Then deploy it:

```pwsh
    kubectl apply -f {file name}
```

## Deploying Secret

Create file:

```yaml
#Crear secretoapiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: {service account name}-sa
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: "{service account name}"
```

Then deploy it:

```pwsh
    kubectl apply -f {file name}
```

## Getting Control Plane URL

```pwsh
    kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
```

## Getting Secret Token from Cluster

```pwsh
    kubectl get secret {service account name}-sa -n kube-system -o json
```

## Creating the Service Connection's Configfile

Define the corresponding configfile in json format.

```json
{
  "authorization": {
    "parameters": {
      "serviceAccountCertificate": {Secret Token gotten from the cluster in previous step 'Getting Secret Token from Cluster'}
    },
    "scheme": "Token"
  },
  "data": {
    "authorizationType": "ServiceAccount"
  },
  "description": "",
  "isReady": true,
  "isShared": false,
  "name": {AKS name},
  "operationStatus": null,
  "owner": "Library",
  "readersGroup": null,
  "serviceEndpointProjectReferences": [
    {
      "description": "",
      "name": {AKS name},
      "projectReference": {
        "id": {Existing Devops Project ID},
        "name": {Existing Devops Project Name}
      }
    }
  ],
  "type": "kubernetes",
  "url": {Control Plane URL gotten from the cluster in previous step 'Getting Control Plane URL'}
}
```

These are some useful links when defining a custom configfile:

* [Azure Devops Service Endpoint][CreateDevopsEndPoint]
* [Kubernetes Endpoint][KubernetesEndpoint]
* [Listing Types of Endpoints][APIGetEndpointTypes]

An example request through pipeline to [Azure Devops API][APIGetEndpointTypes] in order to list Endpoint Types:

```pwsh
# REMEMBER TO SET 'Allow scripts to access the OAuth token' IN THE AGENT
# Define token user:token as base64 
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(("{0}:{1}" -f "user","$(System.AccessToken)")))
# Set authorization header
$headers = @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    
(Invoke-RestMethod -Uri "https://dev.azure.com/{Organization name}/_apis/serviceendpoint/types?api-version=7.0" -Headers $headers -Method Get).Value
```

## Creating the Service Connection through API request

In case of necessity, here's the [Microsoft Documentation][APICreateEndpoint].

Request through Azure Devops Pipeline:

```pwsh
# REMEMBER TO SET 'Allow scripts to access the OAuth token' IN THE AGENT
# Define token user:token as base64 
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(("{0}:{1}" -f "user","$(System.AccessToken)")))
# Set authorization header
$headers = @{Authorization=("Basic {0}" -f $base64AuthInfo)}

Invoke-RestMethod -Headers $headers -Method Post -Uri "https://dev.azure.com/{organization name}/_apis/serviceendpoint/endpoints?api-version=$(devops_api_version)" -ContentType "application/json" -Body $(Get-Content -Raw -Encoding utf8 {config file})
```

[CreateDevopsEndpoint]: https://learn.microsoft.com/en-us/azure/devops/cli/service-endpoint?view=azure-devops
[KubernetesEndpoint]: https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml#kubernetes-service-connection
[APICreateEndpoint]: https://learn.microsoft.com/en-us/rest/api/azure/devops/serviceendpoint/endpoints/create?view=azure-devops-rest-7.0&tabs=HTTP
[APIGetEndpointTypes]: https://learn.microsoft.com/en-us/rest/api/azure/devops/serviceendpoint/types/list?view=azure-devops-rest-7.0&tabs=HTTP