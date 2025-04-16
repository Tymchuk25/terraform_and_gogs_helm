// VPC Module Variables - variables.tf

variable "project_name" {
  description = "Project name prefix for resource naming"
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



