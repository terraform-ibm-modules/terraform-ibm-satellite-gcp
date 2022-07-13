# satellite-google

This example cover end-to-end functionality of IBM cloud satellite by creating satellite location with GCP host. It will provision satellite location and create 6 GCP host and assign 3 host to control plane, and provision ROKS satellite cluster and auto assign 3 host to cluster, Configure cluster worker pool to an existing ROKS satellite cluster.

## Compatibility

This module is meant for use with Terraform 0.13 or later.

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13 or later.
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)
- [terraform-provider-google](https://github.com/hashicorp/terraform-provider-google)
- To authenticate google provider please refer [docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference)

## Install

### Terraform

Be sure you have the correct Terraform version ( 0.13 or later), you can choose the binary here:
- https://releases.hashicorp.com/terraform/

## Usage

```
terraform init
```
```
terraform plan
```
```
terraform apply
```
```
terraform destroy
```

## Example Usage

``` hcl
module "satellite-gcp" {
  source  = "terraform-ibm-modules/satellite-gcp/ibm"
  version = "1.0.0"

  ################# IBM cloud & GCP cloud authentication variables #######################
  ibmcloud_api_key   = var.ibmcloud_api_key       #pragma: allowlist secret
  ibm_resource_group = var.ibm_resource_group
  gcp_project        = var.gcp_project
  gcp_credentials    = var.gcp_credentials        #pragma: allowlist secret
  gcp_region         = var.gcp_region

  ################# Satellite location resource variables #######################
  is_location_exist = var.is_location_exist
  location          = var.location
  managed_from      = var.managed_from
  location_zones    = var.location_zones
  location_bucket   = var.location_bucket
  host_labels       = var.host_labels

  ################# GCP Host variables #######################
  gcp_resource_prefix         = var.gcp_resource_prefix
  satellite_host_count        = var.satellite_host_count
  addl_host_count             = var.addl_host_count
  gcp_security_custom_rules   = var.gcp_security_custom_rules
  control_plane_instance_type = var.control_plane_instance_type
  cluster_instance_type       = var.cluster_instance_type

  ################# Satellite Cluster resource variables #######################
  create_cluster             = var.is_create_cluster
  cluster                    = var.cluster
  cluster_host_labels        = var.cluster_host_labels
  create_cluster_worker_pool = var.create_cluster_worker_pool
  worker_pool_name           = var.worker_pool_name
  worker_pool_host_labels    = var.worker_pool_host_labels
  create_timeout             = var.create_timeout
  update_timeout             = var.update_timeout
  delete_timeout             = var.delete_timeout
}
```

## Note

* `satellite-location` module creates new location or use existing location ID/name to process. If user pass the location which is already exist,   satellite-location module will error out and exit the module. In such cases user has to set `is_location_exist` value to true. So that module will use existing location for processing.
* `satellite-location` module download attach host script to the $HOME directory and appends respective permissions to the script.
* `satellite-location` module will update the attach host script and will be used in the `metadata.startup-script` attribute of `gcp_host-template` module.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| ibmcloud_api_key                      | IBM Cloud API key                                                 | string   | n/a     | yes      |
| ibm_resource_group                    | Resource Group Name that has to be targeted.                      | string   | n/a     | yes      |
| gcp_project                           | GCP Project ID                                                    | string   | n/a     | yes      |
| gcp_region                            | Google Region                                                     | string   | `us-east1`| no       |
| gcp_credentials                       | Either the path to or the contents of a service account key file in JSON format                                                                                                      | string   | n/a     |  yes     |
| location                              | Name of the Location that has to be created                       | string   | satellite-google | yes   |
| is_location_exist                     | Determines if the location has to be created or not               | bool     | false   | yes      |
| managed_from                          | The IBM Cloud region to manage your Satellite location from.      | string   | wdc   | yes      |
| location_zones                        | Allocate your hosts across three zones for higher availablity     | list     | ["us-east1-b", "us-east1-c", "us-east1-d"]    | yes      |
| host_labels                           | Add labels to attach host script                                  | list     | [env:prod]  | no   |
| location_bucket                       | COS bucket name                                                   | string   | n/a     | no       |
| gcp_resource_prefix                   | Name to be used on all google resources as prefix                 | string   | satellite-google     | yes |
| satellite_host_count                  | The total number of google hosts to create for control plane. satellite_host_count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts | number   | 3 |  yes     |
| addl_host_count                       | The total number of additional google hosts                       | number   | 0 |  no    |
| control_plane_instance_type           | The type of gcp instance to start for control plane               | string   | n2-standard-4 | no      |
| cluster_instance_type                 | The type of gcp instance to start for cluster                     | string   | n2-standard-4 | no      |
| ssh_public_key                        | SSH Public Key. Get your ssh key by running `ssh-key-gen` command | string   | n/a     | no |
| is_create_cluster                     | Create cluster                                                    | bool     | true    | no       |
| cluster                               | Name of the ROKS Cluster that has to be created                   | string   | n/a     | yes      |
| cluster_zones                         | Allocate your hosts across these three zones                      | set      | n/a     | yes      |
| kube_version                          | Kuber version                                                     | string   | 4.7_openshift | no |
| default_wp_labels                     | Labels on the default worker pool                                 | map      | n/a     | no       |
| workerpool_labels                     | Labels on the worker pool                                         | map      | n/a     | no       |
| cluster_tags                          | List of tags for the cluster resource                             | list     | n/a     | no       |
| create_cluster_worker_pool            | Create Cluster worker pool                                        | bool     | false   | no       |
| worker_pool_name                      | Worker pool name                                                  | string   | satellite-worker-pool  | no |
| workerpool_labels                     | Labels on the worker pool                                         | map      | n/a     | no       |
| create_timeout                        | Timeout duration for creation                                     | string   | n/a     | no       |
| update_timeout                        | Timeout duration for updation                                     | string   | n/a     | no       |
| delete_timeout                        | Timeout duration for deletion                                     | string   | n/a     | no       |


## Outputs

| Name                            | Description                           |
|---------------------------------|---------------------------------------|
| location_id                     | Location id                           |
| gcp_cp_host_names               | GCP Control plane host name           |
| network                         | GCP Network                           |
| network_name                    | The name of the VPC being createde    |
| firewall_rules                  | The created firewall rule resources   |
| control_plane_instances_details | List of all details for compute instances for control plane |
| cluster_instances_details       | List of all details for compute instances for cluster    |
| cluster_id                      | Cluster Id                              |
| cluster_crn                     | Cluster CRN                             |
| server_url                      | Cluster server URL                      |
| cluster_state                   | Cluster state                           |
| cluster_status                  | Cluster status                          |
| cluster_ingress_hostname        | Cluster ingree hostname                 |
| cluster_worker_pool_id          | Cluster worker pool id                  |
| worker_pool_worker_count        | worker count deatails                   |
| worker_pool_zones               | workerpool zones                        |