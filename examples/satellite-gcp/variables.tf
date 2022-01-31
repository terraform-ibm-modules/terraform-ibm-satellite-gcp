#####################################################
# IBM Cloud Satellite -  GCP
# Copyright 2022 IBM
#####################################################

##########################################################
# GCP and IBM Authentication Variables
##########################################################
variable "TF_VERSION" {
  description = "Terraform version"
  type        = string
  default     = "0.13"
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type        = string
}

variable "ibm_resource_group" {
  description = "Resource group name of the IBM Cloud account."
  type        = string
}

variable "gcp_project" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "Google Region"
  type        = string
  default     = "us-east1"
}

variable "gcp_credentials" {
  description = "Either the path to or the contents of a service account key file in JSON format"
  type        = string
}

###################################################
# IBMCLOUD Satellite Location Variables
###################################################

variable "location" {
  description = "Location Name"
  default     = "satellite-gcp"

  validation {
    condition     = var.location != "" && length(var.location) <= 32
    error_message = "Sorry, please provide value for location_name variable or check the length of name it should be less than 32 chars."
  }
}

variable "is_location_exist" {
  description = "Determines if the location has to be created or not"
  type        = bool
  default     = false
}

variable "managed_from" {
  description = "The IBM Cloud region to manage your Satellite location from. Choose a region close to your on-prem data center for better performance."
  type        = string
  default     = "wdc"
}

variable "location_zones" {
  description = "Allocate your hosts across these three zones"
  type        = list(string)
  default     = ["us-east1-b", "us-east1-c", "us-east1-d"]
}

variable "location_bucket" {
  description = "COS bucket name"
  default     = ""
}

variable "host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = ["env:prod"]

  validation {
    condition     = can([for s in var.host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}

####################################################
# Google Resources Variables
####################################################

variable "gcp_resource_prefix" {
  description = "Name to be used on all gcp resource as prefix"
  type        = string
  default     = "satellite-google"

  validation {
    condition     = var.gcp_resource_prefix != "" && length(var.gcp_resource_prefix) <= 25
    error_message = "Sorry, please provide value for resource_prefix variable or check the length of resource_prefix it should be less than 25 chars."
  }
}

variable "gcp_security_custom_rules" {
  description = "Azure security group custom rules"
  type = list(object({
    name                    = string
    description             = string
    direction               = string
    priority                = number
    ranges                  = list(string)
    source_tags             = list(string)
    source_service_accounts = list(string)
    target_tags             = list(string)
    target_service_accounts = list(string)
    allow = list(object({
      protocol = string
      ports    = list(string)
    }))
    deny = list(object({
      protocol = string
      ports    = list(string)
    }))
    log_config = object({
      metadata = string
    })
  }))

  default = [
    {
      name                    = "satellite-google-ingress"
      description             = "Ingress for satellite-google-vpc"
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = []
      target_service_accounts = null
      allow = [
        {
          protocol = "tcp"
          ports    = ["30000-32767"]
        },
        {
          protocol = "udp"
          ports    = ["30000-32767"]
        }
      ]
      deny       = []
      log_config = null
    },
    {
      name                    = "satellite-google-egress"
      description             = "Egress rules for satellite-google-vpc"
      direction               = "EGRESS"
      priority                = 1000
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = []
      target_service_accounts = null
      allow = [
        {
          protocol = "all"
          ports    = []
        }
      ]
      deny       = []
      log_config = null
    },
    {
      name                    = "satellite-google-private-ingress"
      description             = "Private Ingress rules for satellite-google-vpc"
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = ["10.0.0.0/16"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = []
      target_service_accounts = null
      allow = [
        {
          protocol = "all"
          ports    = []
        }
      ]
      deny       = []
      log_config = null
    },
  ]
}

variable "satellite_host_count" {
  description = "The total number of GCP host to create for control plane. satellite_host_count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts"
  type        = number
  default     = 3
  validation {
    condition     = (var.satellite_host_count % 3) == 0 && var.satellite_host_count > 0
    error_message = "Sorry, host_count value should always be in multiples of 3, such as 6, 9, or 12 hosts."
  }
}

variable "addl_host_count" {
  description = "The total number of additional gcp host"
  type        = number
  default     = 3
}

variable "control_plane_instance_type" {
  description = "The type of gcp instance to start."
  type        = string
  default     = "n2-standard-4"
}

variable "cluster_instance_type" {
  description = "The type of gcp instance to start."
  type        = string
  default     = "n2-standard-4"
}

variable "cluster_disk_size_gb" {
  description = "Boot disk size in GB for cluster host"
  type        = number
  default     = 100
}

variable "ssh_public_key" {
  description = "SSH Public Key. Get your ssh key by running `ssh-key-gen` command"
  type        = string
  default     = null
}

variable "gcp_ssh_user" {
  description = "SSH User of above provided ssh_public_key"
  type        = string
  default     = null
}

##################################################
# IBMCLOUD ROKS Cluster Variables
##################################################

variable "is_create_cluster" {
  description = "Create Cluster"
  type        = bool
  default     = true
}

variable "cluster" {
  description = "Cluster name"
  type        = string
  default     = "satellite-ibm-cluster"

  validation {
    error_message = "Cluster name must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.cluster))
  }
}

variable "kube_version" {
  description = "Satellite Kube Version"
  default     = "4.7_openshift"
}

variable "cluster_host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = ["env:prod"]

  validation {
    condition     = can([for s in var.cluster_host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}

variable "worker_count" {
  description = "Worker Count for default pool"
  type        = number
  default     = 1
}

variable "wait_for_worker_update" {
  description = "Wait for worker update"
  type        = bool
  default     = true
}

variable "default_worker_pool_labels" {
  description = "Label to add default worker pool"
  type        = map(any)
  default     = null
}

variable "tags" {
  description = "List of tags associated with cluster."
  type        = list(string)
  default     = null
}

variable "create_timeout" {
  type        = string
  description = "Timeout duration for create."
  default     = null
}

variable "update_timeout" {
  type        = string
  description = "Timeout duration for update."
  default     = null
}

variable "delete_timeout" {
  type        = string
  description = "Timeout duration for delete."
  default     = null
}

##################################################
# IBMCLOUD ROKS Cluster Worker Pool Variables
##################################################
variable "create_cluster_worker_pool" {
  description = "Create Cluster worker pool"
  type        = bool
  default     = true
}

variable "worker_pool_name" {
  description = "Satellite Location Name"
  type        = string
  default     = "satellite-worker-pool"

  validation {
    error_message = "Cluster name must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.worker_pool_name))
  }

}

variable "worker_pool_host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = ["env:prod"]

  validation {
    condition     = can([for s in var.worker_pool_host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}