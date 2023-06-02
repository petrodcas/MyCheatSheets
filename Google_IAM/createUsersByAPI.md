# Create users in Google Workspace through API

1. Generate a service account in Google Workspace following [this tutorial](https://support.google.com/a/answer/7378726?hl=en)

2. Generate access OAuth 2.0 Client IDs following [this tutorial](https://developers.google.com/workspace/guides/create-credentials?hl=en#oauth-client-id)

3. Generate API credentials following [this tutorial](https://developers.google.com/workspace/guides/create-credentials?hl=en#api-key) and download the file in json format

4. Upload this json file in Azure DevOps at Pipelines/Library/Secure file

5. Activate Admin SDK API in [this link](https://console.cloud.google.com/apis/library/admin.googleapis.com?hl=es-419&project=oval-bot-363913)

6. Delegate workspace domain following [this tutorial](https://developers.google.com/cloud-search/docs/guides/delegation?hl=en). You need to introduce the ***Client ID*** from the API credentials json file and **add this scope**: `https://www.googleapis.com/auth/admin.directory.user`

From now on, the use of OAuth credentials can be delegated to every administrator user of Google Workspace.
