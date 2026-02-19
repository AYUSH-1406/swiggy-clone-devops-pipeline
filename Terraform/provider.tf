provider "aws" {
  region = var.region
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
