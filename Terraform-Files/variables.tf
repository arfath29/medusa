variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "medusa_image" {
  description = "Medusa Docker image"
  type        = string
  default     = "medusajs/medusa:latest"
}

variable "medusa_port" {
  description = "Port Medusa runs on"
  type        = number
  default     = 9000
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}
