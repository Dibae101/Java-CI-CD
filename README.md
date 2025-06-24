# Java Spring Boot CI/CD Pipeline with AWS EKS

A complete CI/CD solution for deploying Java Spring Boot applications to AWS EKS using Jenkins, SonarQube, Docker, Terraform, and Kubernetes.

## Ove## License

This project is licensed under the MIT License.

---

**Built with expertise for modern DevOps practices**This project demonstrates a production-ready CI/CD pipeline that:

- Builds a Java Spring Boot web application
- Performs code quality analysis with SonarQube
- Creates Docker images and pushes to AWS ECR
- Deploys infrastructure using Terraform
- Deploys applications to AWS EKS using Helm
- Includes security scanning and health checks

## Architecture

### Infrastructure

- **AWS EKS**: Managed Kubernetes cluster
- **AWS ECR**: Container registry for Docker images
- **VPC**: Custom networking with public/private subnets
- **ALB**: Application Load Balancer for external access
- **Auto Scaling**: Both horizontal pod and cluster autoscaling

### CI/CD Pipeline

- **Jenkins**: Orchestrates the entire pipeline
- **SonarQube**: Code quality and security analysis
- **Docker**: Containerization
- **Helm**: Kubernetes package management
- **Terraform**: Infrastructure as Code

## Prerequisites

- AWS CLI configured with appropriate permissions
- Docker installed
- Java 8+ installed
- Access to Jenkins, SonarQube, and Nexus servers

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Java-CI-CD
```

### 2. Deploy Infrastructure

```bash
# Initialize and apply Terraform
cd terraform
terraform init
terraform apply
```

### 3. Build and Deploy Application

```bash
# Build the application
./gradlew build

# Deploy using the automated script
chmod +x deploy.sh
./deploy.sh deploy
```

### 4. Verify Deployment

```bash
# Check application health
./healthcheck.sh
```

## Project Structure

```text
├── src/                          # Java Spring Boot source code
├── terraform/                    # Infrastructure as Code
├── kubernetes/                   # Helm charts and K8s manifests
├── Dockerfile                    # Container configuration
├── Jenkinsfile                   # CI/CD pipeline definition
├── Jenkinsfile-EKS              # Enhanced EKS pipeline
├── deploy.sh                     # Deployment automation script
├── healthcheck.sh               # Health verification script
└── DEPLOYMENT_GUIDE.md          # Comprehensive deployment guide
```

## Features

### Application Features

- **Spring Boot Web Application**: Simple web interface
- **Thymeleaf Templates**: Server-side rendering
- **Health Endpoints**: Built-in health checks
- **Gradle Build**: Modern build system

### DevOps Features

- **Multi-stage Pipeline**: Quality gates and approvals
- **Security Scanning**: Trivy container scanning
- **Infrastructure Automation**: Complete Terraform setup
- **Monitoring**: CloudWatch integration
- **Scaling**: Auto-scaling capabilities

## Pipeline Stages

1. **Code Quality Check**: SonarQube analysis
2. **Build & Test**: Gradle build and unit tests
3. **Docker Build**: Create and push container images
4. **Security Scan**: Trivy vulnerability scanning
5. **Infrastructure Deploy**: Terraform apply
6. **Manual Approval**: Quality gate
7. **Application Deploy**: Helm deployment to EKS
8. **Health Check**: Verify deployment success

## Security

- IAM roles and policies for least privilege access
- Private subnets for worker nodes
- Security groups with minimal required access
- Container image scanning
- Kubernetes RBAC

## Monitoring & Observability

- AWS CloudWatch integration
- Kubernetes metrics server
- Application health endpoints
- Centralized logging

## Testing

```bash
# Run unit tests
./gradlew test

# Run health check
kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- curl myjavaapp-myapp:8080
```

## Deployment Options

### Option 1: Jenkins Pipeline

Configure Jenkins with the provided `Jenkinsfile-EKS` for automated deployments.

### Option 2: Manual Deployment

Follow the step-by-step guide in `DEPLOYMENT_GUIDE.md`.

### Option 3: Automated Script

Use the `deploy.sh` script for one-command deployment.

## Configuration

Key configuration files:

- `terraform/terraform.tfvars` - Infrastructure settings
- `kubernetes/myapp/values.yaml` - Application configuration
- `config/environments.yaml` - Environment-specific settings

## Cleanup

```bash
# Remove application
helm uninstall myjavaapp -n javaapp

# Destroy infrastructure
cd terraform
terraform destroy
```

## Documentation

- [Deployment Guide](DEPLOYMENT_GUIDE.md) - Comprehensive setup and troubleshooting
- [Terraform Configuration](terraform/README.md) - Infrastructure details

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For issues and questions:

1. Check the [Deployment Guide](DEPLOYMENT_GUIDE.md)
2. Search existing GitHub issues
3. Create a new issue with detailed information

## 📄 License

This project is licensed under the MIT License.

---

Built with ❤️ for modern DevOps practices



