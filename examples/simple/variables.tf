################################################################################
# Simple Example Variables
################################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "simple-gitops"
}

################################################################################
# Required Variables
################################################################################

variable "cluster_name" {
  description = "Name of the existing EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster is deployed"
  type        = string
}

################################################################################
# GitOps Authentication
################################################################################

variable "gitops_user" {
  description = "GitOps user"
  type        = string
  default     = "gitops"
}

variable "gitops_password" {
  description = "GitOps password or token"
  type        = string
  sensitive   = true
  default     = null
}
