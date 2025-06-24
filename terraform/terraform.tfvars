# AWS Region
aws_region = "us-west-2"

# EKS Cluster Configuration
cluster_name       = "javaapp-eks-cluster"
kubernetes_version = "1.28"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

# Node Group Configuration
node_instance_types = ["t3.medium"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 4

# Application Configuration
app_namespace = "javaapp"
app_version   = "latest"
app_replicas  = 2

# Environment
environment   = "dev"
project_name  = "javaapp"
