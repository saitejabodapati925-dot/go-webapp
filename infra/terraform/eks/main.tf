data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # EKS requires subnets in at least two Availability Zones.
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = merge(
    {
      ManagedBy = "terraform"
      Project   = "go-webapp"
    },
    var.tags,
  )
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs            = local.azs
  public_subnets = [for index, _ in local.azs : cidrsubnet(var.vpc_cidr, 8, index)]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway      = false
  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = local.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.14.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  endpoint_public_access = true
  enabled_log_types      = []

  create_cloudwatch_log_group = false

  encryption_config        = null
  create_kms_key           = false
  attach_encryption_policy = false

  enable_cluster_creator_admin_permissions = true

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      capacity_type  = "ON_DEMAND"
      desired_size   = var.node_desired_size
      instance_types = var.node_instance_types
      max_size       = var.node_max_size
      min_size       = var.node_min_size
    }
  }

  tags = local.tags
}
