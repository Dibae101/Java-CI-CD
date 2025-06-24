# AWS EKS Deployment for Java Spring Boot Application

This Terraform configuration deploys a Java Spring Boot application to AWS EKS (Elastic Kubernetes Service).

## Architecture

The infrastructure includes:

- **VPC**: Custom VPC with public and private subnets across 2 availability zones
- **EKS Cluster**: Managed Kubernetes cluster with logging enabled
- **Node Groups**: Auto-scaling worker nodes in private subnets
- **ECR Repository**: Private container registry for the Java application
- **Load Balancer**: AWS Application Load Balancer for external access
- **Security Groups**: Properly configured security groups for cluster and nodes
- **IAM Roles**: Service roles for EKS cluster and node groups with IRSA support

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **kubectl** installed for cluster management
4. **Helm** installed for application deployment
5. **Docker** for building and pushing container images

## Quick Start

### 1. Configure AWS Credentials

```bash
aws configure
```

### 2. Initialize Terraform

```bash
cd terraform
terraform init
```

### 3. Review and Modify Variables

Edit `terraform.tfvars` to customize your deployment:

```hcl
aws_region         = "us-west-2"
cluster_name       = "javaapp-eks-cluster"
kubernetes_version = "1.28"
vpc_cidr          = "10.0.0.0/16"
node_instance_types = ["t3.medium"]
node_desired_size  = 2
app_namespace     = "javaapp"
app_version       = "latest"
```

### 4. Plan the Deployment

```bash
terraform plan
```

### 5. Deploy the Infrastructure

```bash
terraform apply
```

This will create:
- Complete EKS cluster infrastructure
- ECR repository for your Java application
- Deploy the application using the existing Helm charts

### 6. Configure kubectl

```bash
aws eks update-kubeconfig --region us-west-2 --name javaapp-eks-cluster
```

### 7. Build and Push Docker Image

```bash
# Navigate to your application root
cd ..

# Build the application
./gradlew build

# Get ECR login token
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <ecr-repository-url>

# Build and tag the Docker image
docker build -t <ecr-repository-url>:latest .

# Push the image
docker push <ecr-repository-url>:latest
```

### 8. Verify Deployment

```bash
# Check cluster status
kubectl get nodes

# Check application deployment
kubectl get pods -n javaapp

# Get application URL
kubectl get svc -n javaapp
```

## Application Access

The application will be accessible via the AWS Load Balancer URL, which you can get from:

```bash
terraform output application_url
```

Or check the service in Kubernetes:

```bash
kubectl get svc -n javaapp -o wide
```

## Monitoring and Logging

### Cluster Logs
EKS cluster logging is enabled for:
- API server
- Audit
- Authenticator
- Controller manager
- Scheduler

View logs in CloudWatch under `/aws/eks/<cluster-name>/cluster`

### Application Logs
```bash
# View application logs
kubectl logs -f deployment/myjavaapp-myapp -n javaapp

# View all pods in namespace
kubectl get pods -n javaapp
```

## Scaling

### Horizontal Pod Autoscaling
```bash
kubectl autoscale deployment myjavaapp-myapp --cpu-percent=50 --min=2 --max=10 -n javaapp
```

### Cluster Autoscaling
Modify the node group configuration in `terraform.tfvars`:

```hcl
node_min_size     = 1
node_max_size     = 10
node_desired_size = 3
```

Then apply the changes:
```bash
terraform apply
```

## Security Features

- **Private subnets**: Worker nodes run in private subnets
- **Security groups**: Restrictive security group rules
- **IAM roles**: Least privilege access with IRSA
- **ECR image scanning**: Automatic vulnerability scanning
- **Network isolation**: VPC-native networking

## Cost Optimization

- **Spot instances**: Consider using spot instances for non-production
- **Right-sizing**: Monitor and adjust instance types based on usage
- **Auto-scaling**: Configured to scale down during low usage

## Troubleshooting

### Common Issues

1. **ECR Authentication**:
   ```bash
   aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <ecr-url>
   ```

2. **kubectl Access**:
   ```bash
   aws eks update-kubeconfig --region us-west-2 --name javaapp-eks-cluster
   ```

3. **Pod Issues**:
   ```bash
   kubectl describe pod <pod-name> -n javaapp
   kubectl logs <pod-name> -n javaapp
   ```

4. **Service Issues**:
   ```bash
   kubectl describe svc -n javaapp
   kubectl get endpoints -n javaapp
   ```

### Useful Commands

```bash
# Get cluster info
kubectl cluster-info

# Get all resources in namespace
kubectl get all -n javaapp

# Port forward for local testing
kubectl port-forward svc/myjavaapp-myapp 8080:8080 -n javaapp

# Execute into pod
kubectl exec -it <pod-name> -n javaapp -- /bin/bash

# Check node resource usage
kubectl top nodes

# Check pod resource usage
kubectl top pods -n javaapp
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all resources including the EKS cluster, VPC, and any data in ECR.

## CI/CD Integration

The existing Jenkinsfile can be modified to use this EKS cluster:

1. Replace Docker registry references with ECR repository URL
2. Update kubectl commands to target the EKS cluster
3. Configure Jenkins with AWS credentials and EKS access

Example Jenkins pipeline modification:

```groovy
stage ("Docker Build and Docker Push"){
    steps{
        script{
            withCredentials([string(credentialsId: 'aws_access_key', variable: 'AWS_ACCESS_KEY_ID'),
                           string(credentialsId: 'aws_secret_key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                sh '''
                    aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <ecr-repository-url>
                    docker build -t <ecr-repository-url>:${VERSION} .
                    docker push <ecr-repository-url>:${VERSION}
                    docker rmi <ecr-repository-url>:${VERSION}
                '''
            }
        }
    } 
}
```

## Support

For issues and questions:
1. Check the AWS EKS documentation
2. Review Terraform AWS provider documentation
3. Check Kubernetes documentation for kubectl commands
4. Review application logs and Kubernetes events

## File Structure

```
terraform/
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable definitions
├── outputs.tf          # Output definitions
├── terraform.tf        # Terraform configuration
├── terraform.tfvars    # Variable values
├── iam-policy.json     # AWS Load Balancer Controller IAM policy
├── kubeconfig.tpl      # kubectl configuration template
└── README.md           # This file
```
