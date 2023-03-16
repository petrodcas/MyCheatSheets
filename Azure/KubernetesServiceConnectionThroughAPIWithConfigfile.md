# Creating Kubernetes Service Connection through ConfigFile and API request

Steps to create a Kubernetes Service Connection in azure devops through commands.

## [Table of content][init]

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

## [Creating Service Account in Kubernetes Cluster][init]

```pwsh
    az account set -s {subscription Name or ID}
    az aks get-credentials --resource-group {resource group name} --name {AKS name}
    kubectl create serviceaccount {service account name} -n {namespace name}
```

**Note:** These commands are required to swap the cluster context through **PIPELINE**.

```pwsh
    # Convert kubeconfig to a valid format
    kubelogin convert-kubeconfig -l azurecli

    # Swap context
    kubectl config use-context $(aks_name)
```

## [Deploying ClusterRoleBinding][init]

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

## [Deploying Secret][init]

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

## [Getting Control Plane URL][init]

```pwsh
    kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
```

## [Getting Secret Token from Cluster][init]

```pwsh
    kubectl get secret {service account name}-sa -n kube-system -o json
```

**Note**: These commands can be used in order to pick the needed data from the previous request:

```pwsh
  # Get secret
  $secret = (kubectl get secret $(service_account_name)-sa -n kube-system -o json) | ConvertFrom-Json
  # Get apitoken
  $apiToken = $secret.data.token
  # Get serviceAccountCertificate
  $serviceAccountCertificate = $secret.data."ca.crt"
```

## [Creating the Service Connection's Configfile][init]

Define the corresponding configfile in json format.

**Sample configfile for a ServiceAccount authorization type:**

```json
{
  "authorization": {
    "parameters": {
      "serviceAccountCertificate": {ca.crt gotten from the cluster's secret in previous step 'Getting Secret Token from Cluster'},
      "apiToken": {token gotten from the cluster's secret in previous step 'Getting Secret Token from Cluster'}
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

An example request to [Azure Devops API][APIGetEndpointTypes] in order to list Endpoint Types:

```pwsh
# REMEMBER TO CREATE A PERSONAL ACCESS TOKEN IN AZURE DEVOPS

# Define token user:token as base64 using PAT
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(("{0}:{1}" -f "$(Personal_Access_Token)","")))
# Set authorization header
$headers = @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    
(Invoke-RestMethod -Uri "https://dev.azure.com/{Organization name}/_apis/serviceendpoint/types?api-version=7.0" -Headers $headers -Method Get).Value
```

## [Creating the Service Connection through API request][init]

In case of necessity, here's the [Microsoft Documentation][APICreateEndpoint].

```pwsh
# REMEMBER TO CREATE A PERSONAL ACCESS TOKEN IN AZURE DEVOPS

# Define token user:token as base64 using PAT
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(("{0}:{1}" -f "$(Personal_Access_Token)","")))
# Set authorization header
$headers = @{Authorization=("Basic {0}" -f $base64AuthInfo)}

Invoke-RestMethod -Headers $headers -Method Post `
  -Uri "https://dev.azure.com/{organization name}/_apis/serviceendpoint/endpoints?api-version=7.0" `
  -ContentType "application/json" -Body $(Get-Content -Raw -Encoding utf8 {config file})
```

## [Setting "Grant access permission to all pipelines" option][init]

In case of necessity, here's the [Microsoft Documentation][APIGrantPipelinePermissions].

Define the next json to be used by the request:

```json
  {
    "allPipelines": {
        "authorized": true,
        "authorizedBy": null,
        "authorizedOn": null
    },
    "pipelines": null
}
```

Then execute the next lines:

```pwsh
  # REMEMBER TO CREATE A PERSONAL ACCESS TOKEN IN AZURE DEVOPS

  # Define token user:token as base64 using PAT
  $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(("{0}:{1}" -f "$(Personal_Access_Token)","")))
  # Set authorization header
  $headers = @{Authorization=("Basic {0}" -f $base64AuthInfo)}

  # Gets the endpoint ID through API
  $id_endpoint = (Invoke-RestMethod -Headers $headers -Method Get `
    -Uri "https://dev.azure.com/$(organization_name)/$(project_name)/_apis/serviceendpoint/endpoints?endpointNames=$(service_connection_name)&api-version=7.0").value.id

  # Grants access permission using the previously defined json
  Invoke-RestMethod -Headers $headers -Method Patch `
    -Uri "https://dev.azure.com/$(organization_name)/$(project_name)/_apis/pipelines/pipelinePermissions/endpoint/$id_endpoint`?api-version=7.0-preview.1" `
    -ContentType "application/json" -Body $(Get-Content -Raw -Encoding utf8 "$(json_file)")
```

[CreateDevopsEndpoint]: https://learn.microsoft.com/en-us/azure/devops/cli/service-endpoint?view=azure-devops
[KubernetesEndpoint]: https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml#kubernetes-service-connection
[APICreateEndpoint]: https://learn.microsoft.com/en-us/rest/api/azure/devops/serviceendpoint/endpoints/create?view=azure-devops-rest-7.0&tabs=HTTP
[APIGetEndpointTypes]: https://learn.microsoft.com/en-us/rest/api/azure/devops/serviceendpoint/types/list?view=azure-devops-rest-7.0&tabs=HTTP
[APIGrantPipelinePermissions]: https://learn.microsoft.com/en-us/rest/api/azure/devops/approvalsandchecks/pipeline-permissions/update-pipeline-permisions-for-resource?view=azure-devops-rest-7.0&tabs=HTTP
[init]: #creating-kubernetes-service-connection-through-configfile-and-api-request