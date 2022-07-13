# IBM Cloud Satellite location on GCP

Use this terrafrom automation to set up satellite location on IBM cloud with google cloud host.
It will provision satellite location and create 6 gcp host and assign 3 host to control plane, and provision ROKS satellite cluster and auto assign 3 host to cluster,
Configure cluster worker pool to an existing ROKS satellite cluster.

This is a collection of modules that make it easier to provision a satellite on IBM Cloud.
* satellite-location
* satellite-assign-host
* satellite-cluster
* satellite-cluster-worker-pool

## Overview

IBM Cloud® Satellite helps you deploy and run applications consistently across all on-premises, edge computing and public cloud environments from any cloud vendor. It standardizes a core set of Kubernetes, data, AI and security services to be centrally managed as a service by IBM Cloud, with full visibility across all environments through a single pane of glass. The result is greater developer productivity and development velocity.

https://cloud.ibm.com/docs/satellite?topic=satellite-getting-started

## Features

- Create satellite location.
- Create 6 gcp host with rhel-7.
- Assign the 3 hosts to the location control plane.
- *Conditional creation*:
  * Create a Red Hat OpenShift on IBM Cloud cluster and assign the 3 hosts to the cluster, so that you can run OpenShift workloads in your location.
  * Configure a worker pool to an existing OpenShift Cluster.

<table cellspacing="10" border="0">
  <tr>
    <td>
      <img src="images/providers/satellite.png" />
    </td>
  </tr>
</table>

## Compatibility

This module is meant for use with Terraform 0.13 or later.

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13 or later.
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)

## Install

### Terraform

Be sure you have the correct Terraform version ( 0.13 or later), you can choose the binary here:
- https://releases.hashicorp.com/terraform/

### Terraform provider plugins

Be sure you have the compiled plugins on $HOME/.terraform.d/plugins/

- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)
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
provider "google" {
  project     = var.gcp_project
  region      = var.gcp_region
  credentials = var.gcp_credentials       #pragma: allowlist secret
}

provider "google-beta" {
  project     = var.gcp_project
  region      = var.gcp_region
  credentials = var.gcp_credentials         #pragma: allowlist secret
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key    #pragma: allowlist secret
}

module "satellite-gcp" {
  source  = "terraform-ibm-modules/satellite-gcp/ibm"
  version = "1.0.0"

  ################# IBM cloud & GCP cloud authentication variables #######################
  ibm_resource_group = var.ibm_resource_group
  gcp_project        = var.gcp_project
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
  create_cluster             = var.create_cluster
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
* `satellite-location` module will update the attach host script and will be used in the `custom_data` attribute of `gcprm_linux_virtual_machine` resource.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| ibmcloud_api_key                      | IBM Cloud API key                                                 | string   | n/a     | yes      |
| ibm_resource_group                    | Resource Group Name that has to be targeted.                      | string   | n/a     | yes      |
| gcp_project                           | GCP Project ID                                                    | string   | n/a     | yes      |
| gcp_region                            | Google Region                                                     | string   | us-east1| no       |
| gcp_credentials                       | Either the path to or the contents of a service account key file in JSON format                                                                                                      | string   | n/a     |  yes     |
| location                              | Name of the Location that has to be created                       | string   | n/a     | satellite-gcp  |
| is_location_exist                     | Determines if the location has to be created or not               | bool     | false   | no       |
| managed_from                          | The IBM Cloud region to manage your Satellite location from.      | string   | wdc     | no       |
| location_zones                        | Allocate your hosts across three zones for higher availablity     | list     | []      | no       |
| host_labels                           | Add labels to attach host script                                  | list     | [env:prod]  | no   |
| location_bucket                       | COS bucket name                                                   | string   | n/a     | no       |
| ssh_public_key                        | Public SSH key used to provision Host/VSI                         | string   | n/a     | no       |
| gcp_security_custom_rules             | Google security group custom rules                                | list(object)   | n/a | no |
| gcp_resource_prefix                   | Name to be used on all gcp resource as prefix                     | string   | satellite-google | no |
| satellite_host_count                  | The total number of host to create for control plane. host_count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts | number | 3 |  yes |
| addl_host_count                       | The total number of additional host                               | number   | 0       | no       |
| control_plane_instance_type           | The type of gcp instance to start for control plane               | string   | n2-standard-4 | no      |
| control_plane_vm_access_config        | Access configurations, i.e. IPs via which the VM instance can be accessed via the Internet. for control plane               | list(object)   | n/a | no      |
| control_plane_source_image_project    | Project where the source image comes from for control plane host  | string   | rhel-cloud    | no      |
| control_plane_vm_disk_size_gb         | Boot disk size in GB for control plane host                       | number   | 100    | no      |
| control_plane_vm_source_image_family  | Source disk image for control plane host                          | string   | rhel-7 | no      |
| control_plane_vm_disk_type            | Boot disk type, can be either pd-ssd, local-ssd, or pd-standard for control plane host| string   | pd-ssd    | no      |
| cluster_instance_type                 | The type of gcp instance to start for cluster                     | string   | n2-standard-4 | no      |
| cluster_vm_access_config              | Access configurations, i.e. IPs via which the VM instance can be accessed via the Internet. for cluster  | list(object)   | n/a | no      |
| cluster_source_vm_image_project       | Project where the source image comes from for cluster host        | string   | rhel-cloud    | no      |
| cluster_vm_disk_size_gb               | Boot disk size in GB for cluster  host                            | number   | 100           | no      |
| cluster_vm_disk_type                  | Boot disk type, can be either pd-ssd, local-ssd, or pd-standard for cluster host| string   | pd-ssd    | no      |
| cluster_vm_source_image_family     |   Source disk image for cluster host                          | string   | rhel-7 | no      |
| create_cluster                        | Create cluster                                                    | bool     | true    | no       |
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

## Pre-commit Hooks

Run the following command to execute the pre-commit hooks defined in `.pre-commit-config.yaml` file

  `pre-commit run -a`

We can install pre-coomit tool using

  `pip install pre-commit`

## How to input varaible values through a file

To review the plan for the configuration defined (no resources actually provisioned)

`terraform plan -var-file=./input.tfvars`

To execute and start building the configuration defined in the plan (provisions resources)

`terraform apply -var-file=./input.tfvars`

To destroy the VPC and all related resources

`terraform destroy -var-file=./input.tfvars`

All optional parameters by default will be set to null in respective example's varaible.tf file. If user wants to configure any optional paramter he has overwrite the default value.