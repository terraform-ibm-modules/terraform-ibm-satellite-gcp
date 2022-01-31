#####################################################
# IBM Cloud Satellite -  GCP
# Copyright 2022 IBM
#####################################################

locals {
  control_plane_hosts = [for instance in module.gcp_control_plane_hosts.instances_details : instance.name]
}