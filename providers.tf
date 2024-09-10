#
terraform {
  required_version = "= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67.0"
      configuration_aliases = [
        aws,
      ]
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

provider "kubernetes" {
  host                   = local.eks.endpoint
  cluster_ca_certificate = base64decode(local.eks.certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args = [
      "eks", "get-token",
      "--profile", local.aws_profile,
      "--cluster-name", local.eks.id
    ]
    command = "aws"
  }
}

provider "kubectl" {
  host                   = local.eks.endpoint
  cluster_ca_certificate = base64decode(local.eks.certificate_authority_data)
  load_config_file       = false
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args = [
      "eks",
      "get-token",
      "--profile", local.aws_profile,
      "--cluster-name", local.eks.id
    ]
    command = "aws"
  }
}
#
provider "aws" {
  region  = var.region
  profile = local.aws_profile
}
#
