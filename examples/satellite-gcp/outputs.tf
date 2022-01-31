#####################################################
# IBM Cloud Satellite -  GCP
# Copyright 2022 IBM
#####################################################

output "location_id" {
  value = module.satellite-gcp.location_id
}

output "gcp_cp_host_names" {
  value = module.satellite-gcp.gcp_cp_host_names
}

output "network" {
  value = module.satellite-gcp.network
}

output "network_name" {
  value = module.satellite-gcp.network_name
}

output "firewall_rules" {
  value = module.satellite-gcp.firewall_rules
}

output "control_plane_instances_details" {
  value     = module.satellite-gcp.control_plane_instances_details
  sensitive = true
}

output "cluster_id" {
  value = module.satellite-gcp.cluster_id
}

output "cluster_crn" {
  value = module.satellite-gcp.cluster_crn
}

output "server_url" {
  value = module.satellite-gcp.server_url
}

output "cluster_state" {
  value = module.satellite-gcp.cluster_state
}

output "cluster_status" {
  value = module.satellite-gcp.cluster_status
}

output "cluster_worker_pool_id" {
  value = module.satellite-gcp.cluster_worker_pool_id
}

output "worker_pool_worker_count" {
  value = module.satellite-gcp.worker_pool_worker_count
}

output "worker_pool_zones" {
  value = module.satellite-gcp.worker_pool_zones
}