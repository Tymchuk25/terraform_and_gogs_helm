data "aws_caller_identity" "current" {}

data "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [helm_release.nginx_ingress]
}

// VPC module
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs = var.azs
  common_tags = var.common_tags
}

// EKS IAM module
module "eks_admin" {
  source = "./modules/iam"
}

//Official module for eks cluster
module "eks" {
   source  = "terraform-aws-modules/eks/aws"
   version = "~> 19.15.4"

   cluster_name = var.cluster_name
   cluster_version = var.cluster_version

   vpc_id = module.vpc.vpc_id
   subnet_ids = module.vpc.private_subnet_ids

   enable_irsa = true

  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = true
  #cluster_endpoint_public_access_cidrs     = ["xxx/32"]

  eks_managed_node_groups = {
    default = {
        min_size = 1
        max_size = 1
        desired_size = 1
        instance_types = ["t3.small"]
    }
  }

  manage_aws_auth_configmap = false
  
  aws_auth_roles = [
    {
    rolearn = module.eks_admin.eks_admin_role_arn
    username = "eks-admin"
    groups = ["system:masters"]
  }
]

  providers = {
    kubernetes = kubernetes
  }
}

resource "aws_security_group" "rds_sg" {
  name = "${var.project_name}-rds-sg"
  description = "Security group for RDS MySQL instance"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = var.rds_allowed_cidrs
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.project_name}-rds-sg"
  }, var.common_tags)
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "${var.project_name}-rds-subnet-group"
  subnet_ids = module.vpc.private_subnet_ids

  tags = merge({
    Name = "${var.project_name}-rds-subnet-group"
  }, var.common_tags)
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier = "${var.project_name}-rds"

  engine = "mysql"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  allocated_storage = var.allocated_storage
  storage_type = "gp2"
  port = 3306

  db_name = var.db_name
  username = var.db_master_username
  password = var.db_master_password
  family = var.family
  major_engine_version = "8.0"
 
  multi_az = var.multi_az
  publicly_accessible = var.publicly_accessible
  backup_retention_period = var.backup_retention_period
  deletion_protection = false
  skip_final_snapshot = true

  create_db_subnet_group = false
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

    # IAM Monitoring
  # monitoring_interval    = 30
   create_monitoring_role = false
  # monitoring_role_name   = "${var.project_name}-rds-monitoring-role"

    tags = merge({
    Name = "${var.project_name}-rds"
  }, var.common_tags)
}

resource "helm_release" "nginx_ingress" {
  name = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true
  chart      = "ingress-nginx"

  set {
    name = "service.type"
    value = "LoadBalancer"
  }
  timeout    = 600
  depends_on = [module.eks]
}

resource "helm_release" "gogs" {
  name = "gogs"
  chart = "${path.module}/charts/helm-gogs"
  namespace = "gogs"
  create_namespace = true

  set { 
    name = "env.DB_HOST"
    value = module.rds.db_instance_endpoint
  }

  set {
    name = "env.GOGS_EXTERNAL_URL"
    value = "http://${data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].hostname}"
  }

  depends_on = [
    helm_release.nginx_ingress,
    module.rds
  ]
}