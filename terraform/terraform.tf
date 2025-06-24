# Terraform Configuration File
terraform {
  # Uncomment and configure for remote state storage
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "eks/terraform.tfstate"
  #   region = "us-west-2"
  # }
}

# Local backend for development
# For production, use remote backend like S3
