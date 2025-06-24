# AWS EKS Deployment Guide for Java Spring Boot Application

## Overview

This repository contains a complete CI/CD solution for deploying a Java Spring Boot application to AWS EKS (Elastic Kubernetes Service) using Terraform for infrastructure as code.

## 🏗️ Architecture

### Infrastructure Components
- **AWS EKS Cluster**: Managed Kubernetes service
- **VPC**: Custom VPC with public/private subnets across 2 AZs
- **ECR**: Private container registry for Java application images
- **ALB**: Application Load Balancer for external access
- **Auto Scaling**: Horizontal Pod Autoscaler and Cluster Autoscaler
- **Security**: IAM roles, Security Groups, and RBAC

### Application Stack
- **Java Spring Boot**: Web application framework
- **Thymeleaf**: Template engine for web UI
- **Gradle**: Build tool
- **Docker**: Containerization
- **Helm**: Kubernetes package manager

## 📋 Prerequisites

### Required Tools
1. **AWS CLI** (v2.x)
2. **Terraform** (>= 1.0)
3. **kubectl** (>= 1.28)
4. **Helm** (>= 3.0)
5. **Docker** (>= 20.0)
6. **Java** (>= 8)

### AWS Setup
```bash
# Configure AWS credentials
aws configure

# Verify access
aws sts get-caller-identity
```

### Install Tools (macOS)
```bash
# Install using Homebrew
brew install awscli terraform kubectl helm docker

# Or using official installers
# AWS CLI: https://aws.amazon.com/cli/
# Terraform: https://terraform.io/downloads
# kubectl: https://kubernetes.io/docs/tasks/tools/
# Helm: https://helm.sh/docs/intro/install/
```

## 🚀 Quick Deployment

### Option 1: Automated Deployment Script
```bash
# Clone repository
git clone <repository-url>
cd Java-CI-CD

# Make script executable
chmod +x deploy.sh

# Deploy everything
./deploy.sh deploy

# Check deployment
./deploy.sh verify
```

### Option 2: Manual Step-by-Step Deployment

#### Step 1: Initialize Terraform
```bash
cd terraform
terraform init
```

#### Step 2: Configure Environment
```bash
# Edit terraform.tfvars for your environment
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

#### Step 3: Deploy Infrastructure
```bash
# Plan deployment
terraform plan

# Apply changes
terraform apply
```

#### Step 4: Configure kubectl
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name javaapp-eks-cluster

# Verify cluster access
kubectl get nodes
```

#### Step 5: Build and Push Application
```bash
# Go back to root directory
cd ..

# Build application
./gradlew build

# Get ECR repository URL
ECR_REPO=$(terraform -chdir=terraform output -raw ecr_repository_url)

# Login to ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $ECR_REPO

# Build and push image
docker build -t $ECR_REPO:latest .
docker push $ECR_REPO:latest
```

#### Step 6: Deploy Application
```bash
# Deploy using Helm
helm upgrade --install myjavaapp ./kubernetes/myapp \
    --namespace javaapp \
    --create-namespace \
    --set image.repository=$ECR_REPO \
    --set image.tag=latest \
    --wait
```

## 🔧 Configuration

### Environment Variables
Key configuration files:
- `terraform/terraform.tfvars` - Infrastructure settings
- `config/environments.yaml` - Environment-specific configs
- `kubernetes/myapp/values.yaml` - Helm chart values

### Customization Options

#### Infrastructure Scaling
```hcl
# terraform/terraform.tfvars
node_instance_types = ["t3.medium", "t3.large"]
node_desired_size   = 3
node_min_size       = 1
node_max_size       = 10
```

#### Application Configuration
```yaml
# kubernetes/myapp/values.yaml
replicaCount: 3
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

## 🔄 CI/CD Pipeline

### Jenkins Pipeline
The repository includes two Jenkins pipeline files:
- `Jenkinsfile` - Original pipeline for traditional infrastructure
- `Jenkinsfile-EKS` - Enhanced pipeline for EKS deployment

#### Pipeline Stages
1. **Code Checkout**
2. **SonarQube Quality Gate**
3. **Docker Build & Push to ECR**
4. **Security Scanning with Trivy**
5. **Helm Chart Validation**
6. **Infrastructure Deployment**
7. **Manual Approval**
8. **Application Deployment**
9. **Health Checks**
10. **Performance Testing**

#### Jenkins Configuration
Required Jenkins plugins:
- AWS Pipeline Plugin
- Kubernetes CLI Plugin
- SonarQube Scanner Plugin
- Email Extension Plugin
- Pipeline Stage View Plugin

#### Required Credentials
Configure in Jenkins:
- `aws_access_key_id` - AWS Access Key
- `aws_secret_access_key` - AWS Secret Key
- `sonarapp` - SonarQube token
- GitHub SSH key for repository access

### GitHub Actions (Alternative)
```yaml
# .github/workflows/deploy.yml
name: Deploy to EKS
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to EKS
        run: ./deploy.sh deploy
```

## 📊 Monitoring & Observability

### Cluster Monitoring
```bash
# Install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# View resource usage
kubectl top nodes
kubectl top pods -n javaapp
```

### Application Logs
```bash
# View application logs
kubectl logs -f deployment/myjavaapp-myapp -n javaapp

# Stream logs from all pods
kubectl logs -f -l app.kubernetes.io/instance=myjavaapp -n javaapp
```

### AWS CloudWatch Integration
EKS cluster logs are automatically sent to CloudWatch:
- `/aws/eks/javaapp-eks-cluster/cluster`

## 🔒 Security Best Practices

### Network Security
- Private subnets for worker nodes
- Security groups with least privilege access
- VPC CNI for pod networking

### Access Control
- IAM roles for service accounts (IRSA)
- Kubernetes RBAC
- ECR image scanning

### Secrets Management
```bash
# Create secrets for database credentials
kubectl create secret generic db-credentials \
    --from-literal=username=admin \
    --from-literal=password=secretpassword \
    -n javaapp
```

## 🔧 Troubleshooting

### Common Issues

#### 1. ECR Authentication
```bash
# Re-authenticate with ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <ecr-url>
```

#### 2. kubectl Access
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name javaapp-eks-cluster

# Verify context
kubectl config current-context
```

#### 3. Pod Issues
```bash
# Describe pod for events
kubectl describe pod <pod-name> -n javaapp

# Check pod logs
kubectl logs <pod-name> -n javaapp

# Execute into pod
kubectl exec -it <pod-name> -n javaapp -- /bin/bash
```

#### 4. Load Balancer Issues
```bash
# Check service status
kubectl get svc -n javaapp

# Describe service for events
kubectl describe svc myjavaapp-myapp -n javaapp

# Check endpoints
kubectl get endpoints -n javaapp
```

### Debug Commands
```bash
# Cluster info
kubectl cluster-info

# Node status
kubectl get nodes -o wide

# All resources in namespace
kubectl get all -n javaapp

# Events in namespace
kubectl get events -n javaapp --sort-by=.metadata.creationTimestamp
```

## 📈 Scaling

### Horizontal Pod Autoscaling
```bash
# Create HPA
kubectl autoscale deployment myjavaapp-myapp --cpu-percent=50 --min=2 --max=10 -n javaapp

# Check HPA status
kubectl get hpa -n javaapp
```

### Cluster Autoscaling
Cluster Autoscaler is automatically configured to scale nodes based on pod demands.

### Manual Scaling
```bash
# Scale deployment
kubectl scale deployment myjavaapp-myapp --replicas=5 -n javaapp

# Scale node group (via Terraform)
terraform apply -var="node_desired_size=5"
```

## 💰 Cost Optimization

### Recommendations
1. **Use Spot Instances** for non-production workloads
2. **Right-size instances** based on actual usage
3. **Enable cluster autoscaling** to scale down during low usage
4. **Use Fargate** for sporadic workloads
5. **Regular cost reviews** using AWS Cost Explorer

### Cost Monitoring
```bash
# Check node utilization
kubectl top nodes

# Check pod resource requests vs limits
kubectl describe pods -n javaapp | grep -A 3 "Requests\|Limits"
```

## 🧹 Cleanup

### Remove Application
```bash
# Delete Helm release
helm uninstall myjavaapp -n javaapp

# Delete namespace
kubectl delete namespace javaapp
```

### Destroy Infrastructure
```bash
cd terraform
terraform destroy
```

### Complete Cleanup
```bash
# Using the deployment script
./deploy.sh cleanup
```

## 📚 Additional Resources

### Documentation Links
- [AWS EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)

### Best Practices
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Spring Boot Best Practices](https://spring.io/guides/topicals/spring-boot-docker/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For issues and questions:
1. Check this documentation
2. Search existing GitHub issues
3. Create a new issue with detailed information
4. Contact the DevOps team

---

**Happy Deploying! 🚀**
