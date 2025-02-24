variable "cluster_name" {
    description = "The name of the EKS cluster"
    type        = string
    default     = "my-eks-cluster"
}

variable "region" {
    description = "The AWS region to deploy the EKS cluster"
    type        = string
    default     = "----------"
}

variable "vpc_id" {
    description = "The VPC ID where the EKS cluster will be deployed"
    type        = string
}

variable "subnet_ids" {
    description = "A list of subnet IDs where the EKS cluster will be deployed"
    type        = list(string)
}

variable "node_instance_type" {
    description = "The instance type for the EKS worker nodes"
    type        = string
    default     = "------"
}

variable "desired_capacity" {
    description = "The desired number of worker nodes"
    type        = number
    default     = 2
}

variable "max_size" {
    description = "The maximum number of worker nodes"
    type        = number
    default     = 3
}

variable "min_size" {
    description = "The minimum number of worker nodes"
    type        = number
    default     = 1
}