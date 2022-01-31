#####################################################
# IBM Cloud Satellite -  GCP
# Copyright 2022 IBM
#####################################################

terraform {
  required_version = ">=0.13"
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    ibm = {
      source = "ibm-cloud/ibm"
    }
  }
}