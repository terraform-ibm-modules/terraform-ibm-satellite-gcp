#####################################################
# IBM Cloud Satellite -  GCP
# Copyright 2022 IBM
#####################################################

terraform {
  required_version = ">=0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.90.1"
    }
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "~> 1.43.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.4.0"
    }
  }
}