terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    kubernetes-alpha = {
      source = "hashicorp/kubernetes-alpha"
    }
    rke = {
      version = ">= 1.1.3"
      source  = "rancher/rke"
    }
  }
  required_version = ">= 0.13"
}
