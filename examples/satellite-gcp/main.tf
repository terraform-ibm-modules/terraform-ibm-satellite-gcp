#####################################################
# IBM Cloud Satellite -  GCP
# Copyright 2022 IBM
#####################################################

###################################################################
# Provision satellite location on IBM cloud with GCP hosts
###################################################################
module "satellite-gcp" {
  source = "../.."

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