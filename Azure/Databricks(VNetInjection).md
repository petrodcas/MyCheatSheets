# Databricks (VNet Injection)[<sup>**1**</sup>](https://learn.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/vnet-inject)

Insert Databricks into existing VNet.

## Understanding Databricks

When created, if no existing resource group is assigned as Databricks workspace, everything needed for its functioning will be deployed on an auto-generated resource group.

Databricks Service needs 2 subnets for its own usage (can't be shared with any other resources or databricks workspaces).

Every cluster node consumes an IP from each subnet (that is, a cluster node has 2 IPs).

One of these subnets is "*public*" - a.k.a. "*host subnet*" - and the other is "*privated*" - a.k.a. "*container subnet*" - (meaning there are no public IP assigned to the nodes nor opened ports). If the workspace uses the option [secure cluster connectivity](https://learn.microsoft.com/en-us/azure/databricks/security/network/secure-cluster-connectivity), then both of the subnets become *privated*.

When defining CIDR for the subnets, remember that Azure reserves 5 host IPs on each subnet, since it limitates the number of cluster nodes that could be deployed.

## Requirements of the VNET

- Must reside in the same region as the Azure Databricks Workspace.
- Must be in the same subscription as the Databricks.
