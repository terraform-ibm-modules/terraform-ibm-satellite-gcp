#####################################################
# IBM Cloud Satellite -  GCP
# Copyright 2022 IBM
#####################################################

output "location_id" {
  value = module.satellite-location.location_id
}

output "gcp_cp_host_names" {
  value = local.control_plane_hosts
}

output "network" {
  value = module.gcp_vpc
}

output "network_name" {
  value = module.gcp_vpc.network_name
}

output "firewall_rules" {
  value = module.gcp_firewall_rules.firewall_rules
}

output "control_plane_instances_details" {
  value     = module.gcp_control_plane_hosts.*
  sensitive = true
}

output "cluster_instances_details" {
  value     = module.gcp_cluster_hosts.*
  sensitive = true
}

output "cluster_id" {
  value = var.create_cluster ? module.satellite-cluster.cluster_id : ""
}

output "cluster_crn" {
  value = var.create_cluster ? module.satellite-cluster.cluster_crn : ""
}

output "server_url" {
  value = var.create_cluster ? module.satellite-cluster.server_url : ""
}

output "cluster_state" {
  value = var.create_cluster ? module.satellite-cluster.cluster_state : ""
}

output "cluster_status" {
  value = var.create_cluster ? module.satellite-cluster.cluster_status : ""
}

output "cluster_ingress_hostname" {
  value = var.create_cluster ? module.satellite-cluster.ingress_hostname : ""
}

output "cluster_worker_pool_id" {
  value = var.create_cluster_worker_pool ? module.satellite-cluster-worker-pool.worker_pool_id : ""
}

output "worker_pool_worker_count" {
  value = var.create_cluster_worker_pool ? module.satellite-cluster-worker-pool.worker_pool_worker_count : ""
}

output "worker_pool_zones" {
  value = var.create_cluster_worker_pool ? module.satellite-cluster-worker-pool.worker_pool_zones : []
}