variable "region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "gogs"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "rds_allowed_cidrs" { //terraform.tfvars
  type        = list(string)
  description = "Private Subnet CIDR values for RDS"
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type = map(string)
  default = {
    Environment = "dev"
    Owner       = "Vitalii"
  }
}

variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
  default     = "gogs-eks"
}

variable "cluster_version" {
  description = "Version of cluster(kubernetes)"
  type = string
  default = "1.29"
}

variable "db_engine_version" { //terraform.tfvars
  description = "MySQL engine version"
  type        = string
  //default = "8.0.40"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage for RDS (in GB)"
  type        = number
  default     = 20
}

variable "multi_az"{ //terraform.tfvars
    description = "Deploy RDS in Multi-AZ configuration"
    type = bool
   // default = false
}

variable "db_name" { //terraform.tfvars
  description = "Name of the PostgreSQL database to create"
  type = string
//  default = "gogs"
}

variable "db_master_username" { //terraform.tfvars
  description = "Master username for RDS"
  type = string
  //default = "gogs"
}

variable "db_master_password" { //terraform.tfvars
  description = "Master password for RDS"
  type = string
 // default = "gogsgogs"
}

variable "publicly_accessible" { //terraform.tfvars
  description = "Should RDS be publicly accessible? (Not recommended for production)"
  type        = bool
 // default = false
}

variable "backup_retention_period" { //terraform.tfvars
  description = "Backup retention period (in days)"
  type = number
  //default = 7
}

variable "family" { //terraform.tfvars
  description = "Parameter group family for the RDS engine"
  type        = string
 // default = "mysql8.0"
}

variable "enable_argocd_app" {
  type    = bool
  default = false
}