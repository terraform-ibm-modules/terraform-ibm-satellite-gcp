#####################################################
# IBM Cloud Satellite -  GCP
# Copyright 2022 IBM
#####################################################

module "satellite-location" {
  source = "terraform-ibm-modules/satellite/ibm//modules/location"

  is_location_exist = var.is_location_exist
  location          = var.location
  managed_from      = var.managed_from
  location_zones    = var.location_zones
  host_labels       = var.host_labels
  resource_group    = var.ibm_resource_group
  host_provider     = "google"
}

##########################################################
# GCP vpc, network, subnetwork and its firewall rules
##########################################################
module "gcp_vpc" {
  source          = "terraform-google-modules/network/google//modules/vpc"
  version         = "~> 3.3.0"
  project_id      = var.gcp_project
  network_name    = "${var.gcp_resource_prefix}-vpc"
  shared_vpc_host = false
}

module "gcp_subnets" {
  source  = "terraform-google-modules/network/google//modules/subnets"
  version = "3.3.0"

  project_id   = var.gcp_project
  network_name = module.gcp_vpc.network_name

  subnets = [
    {
      subnet_name   = "${var.gcp_resource_prefix}-subnet"
      subnet_ip     = "10.0.0.0/16"
      subnet_region = var.gcp_region
    }
  ]
}

module "gcp_firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  version      = "3.3.0"
  project_id   = var.gcp_project
  network_name = module.gcp_vpc.network_name
  rules        = var.gcp_security_custom_rules

  depends_on = [module.gcp_subnets]
}

##########################################################
# GCP Compute Template and Instances
##########################################################
resource "tls_private_key" "rsa_key" {
  count     = (var.ssh_public_key == null ? 1 : 0)
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "gcp_control_plane_host_template" {
  source             = "terraform-google-modules/vm/google//modules/instance_template"
  version            = "6.5.0"
  project_id         = var.gcp_project
  subnetwork         = module.gcp_subnets.subnets["${var.gcp_region}/${var.gcp_resource_prefix}-subnet"].self_link
  subnetwork_project = var.gcp_project
  name_prefix        = "${var.gcp_resource_prefix}-template"
  tags               = ["ibm-satellite", var.gcp_resource_prefix]

  labels = {
    ibm-satellite = var.gcp_resource_prefix
  }

  metadata = {
    ssh-keys       = var.ssh_public_key != null ? "${var.gcp_ssh_user}:${var.ssh_public_key}" : tls_private_key.rsa_key.0.public_key_openssh
    startup-script = module.satellite-location.host_script
  }

  # startup_script=module.satellite-location.host_script
  machine_type         = var.control_plane_instance_type
  can_ip_forward       = false
  source_image_project = var.control_plane_vm_source_image_project
  source_image_family  = var.control_plane_vm_source_image_family
  disk_size_gb         = var.control_plane_vm_disk_size_gb
  disk_type            = var.control_plane_vm_disk_type
  disk_labels = {
    ibm-satellite = var.gcp_resource_prefix
  }

  access_config   = var.control_plane_vm_access_config
  auto_delete     = true
  service_account = { email = "", scopes = [] }

  depends_on = [module.satellite-location, module.gcp_firewall_rules]
}

module "gcp_cluster_host_template" {
  source             = "terraform-google-modules/vm/google//modules/instance_template"
  version            = "6.5.0"
  project_id         = var.gcp_project
  subnetwork         = module.gcp_subnets.subnets["${var.gcp_region}/${var.gcp_resource_prefix}-subnet"].self_link
  subnetwork_project = var.gcp_project
  name_prefix        = "${var.gcp_resource_prefix}-template"
  tags               = ["ibm-satellite", var.gcp_resource_prefix]

  labels = {
    ibm-satellite = var.gcp_resource_prefix
  }

  metadata = {
    ssh-keys       = var.ssh_public_key != null ? "${var.gcp_ssh_user}:${var.ssh_public_key}" : tls_private_key.rsa_key.0.public_key_openssh
    startup-script = module.satellite-location.host_script
  }

  # startup_script=module.satellite-location.host_script
  machine_type         = var.control_plane_instance_type
  can_ip_forward       = false
  source_image_project = var.cluster_vm_source_image_project
  source_image_family  = var.cluster_vm_source_image_family
  disk_size_gb         = var.cluster_vm_disk_size_gb
  disk_type            = var.cluster_vm_disk_type

  disk_labels = {
    ibm-satellite = var.gcp_resource_prefix
  }

  access_config   = var.cluster_vm_access_config
  auto_delete     = true
  service_account = { email = "", scopes = [] }

  depends_on = [module.satellite-location, module.gcp_firewall_rules, module.gcp_control_plane_host_template]
}


module "gcp_control_plane_hosts" {
  source             = "terraform-google-modules/vm/google//modules/compute_instance"
  region             = var.gcp_region
  network            = module.gcp_vpc.network_name
  subnetwork_project = var.gcp_project
  subnetwork         = module.gcp_subnets.subnets["${var.gcp_region}/${var.gcp_resource_prefix}-subnet"].self_link
  num_instances      = var.satellite_host_count
  hostname           = "${var.gcp_resource_prefix}-cp-host"
  instance_template  = module.gcp_control_plane_host_template.self_link

  access_config = [{
    nat_ip       = null
    network_tier = "PREMIUM"
  }]
}

module "gcp_cluster_hosts" {
  source             = "terraform-google-modules/vm/google//modules/compute_instance"
  region             = var.gcp_region
  network            = module.gcp_vpc.network_name
  subnetwork_project = var.gcp_project
  subnetwork         = module.gcp_subnets.subnets["${var.gcp_region}/${var.gcp_resource_prefix}-subnet"].self_link
  num_instances      = var.addl_host_count
  hostname           = "${var.gcp_resource_prefix}-cluster-host"
  instance_template  = module.gcp_cluster_host_template.self_link

  access_config = [{
    nat_ip       = null
    network_tier = "PREMIUM"
  }]
}

###################################################################
# Assign host to satellite location control plane
###################################################################
module "satellite-assign-host" {
  source = "terraform-ibm-modules/satellite/ibm//modules/host"

  host_count     = var.satellite_host_count
  location       = module.satellite-location.location_id
  host_vms       = local.control_plane_hosts
  location_zones = var.location_zones
  host_labels    = var.host_labels
  host_provider  = "google"

  depends_on = [module.gcp_control_plane_hosts]
}

###################################################################
# Create satellite ROKS cluster
###################################################################
module "satellite-cluster" {
  source = "terraform-ibm-modules/satellite/ibm//modules/cluster"

  create_cluster             = var.create_cluster
  cluster                    = var.cluster
  zones                      = var.location_zones
  location                   = module.satellite-location.location_id
  resource_group             = var.ibm_resource_group
  kube_version               = var.kube_version
  worker_count               = var.worker_count
  host_labels                = var.cluster_host_labels
  tags                       = var.tags
  default_worker_pool_labels = var.default_worker_pool_labels
  create_timeout             = var.create_timeout
  update_timeout             = var.update_timeout
  delete_timeout             = var.delete_timeout

  depends_on = [module.satellite-assign-host, module.gcp_cluster_hosts]
}

###################################################################
# Create worker pool on existing ROKS cluster
###################################################################
module "satellite-cluster-worker-pool" {
  source = "terraform-ibm-modules/satellite/ibm//modules/configure-cluster-worker-pool"

  create_cluster_worker_pool = var.create_cluster_worker_pool
  worker_pool_name           = var.worker_pool_name
  cluster                    = var.cluster
  zones                      = var.location_zones
  resource_group             = var.ibm_resource_group
  kube_version               = var.kube_version
  worker_count               = var.worker_count
  host_labels                = var.worker_pool_host_labels
  create_timeout             = var.create_timeout
  delete_timeout             = var.delete_timeout

  depends_on = [module.satellite-cluster]
}