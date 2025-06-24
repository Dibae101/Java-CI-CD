# Deployment Script for Java Spring Boot Application on AWS EKS

#!/bin/bash

set -e

echo "🚀 Starting deployment of Java Spring Boot Application to AWS EKS..."

# Configuration
CLUSTER_NAME="javaapp-eks-cluster"
REGION="us-west-2"
NAMESPACE="javaapp"
APP_NAME="myjavaapp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed"
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed"
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    
    if ! command -v helm &> /dev/null; then
        print_error "Helm is not installed"
        exit 1
    fi
    
    print_status "All prerequisites are installed"
}

# Initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    cd terraform
    terraform init
    cd ..
}

# Deploy infrastructure
deploy_infrastructure() {
    print_status "Deploying EKS infrastructure..."
    cd terraform
    
    if terraform plan -out=tfplan; then
        terraform apply tfplan
        print_status "Infrastructure deployed successfully"
    else
        print_error "Terraform plan failed"
        exit 1
    fi
    
    cd ..
}

# Configure kubectl
configure_kubectl() {
    print_status "Configuring kubectl..."
    aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
    
    # Wait for cluster to be ready
    print_status "Waiting for cluster to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
}

# Build and push Docker image
build_and_push_image() {
    print_status "Building and pushing Docker image..."
    
    # Get ECR repository URL
    ECR_REPO=$(terraform -chdir=terraform output -raw ecr_repository_url)
    
    # Get ECR login token
    aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REPO
    
    # Build the application
    print_status "Building Java application..."
    chmod +x gradlew
    ./gradlew build
    
    # Build Docker image
    print_status "Building Docker image..."
    docker build -t $ECR_REPO:latest .
    
    # Push image
    print_status "Pushing image to ECR..."
    docker push $ECR_REPO:latest
    
    print_status "Image pushed successfully to $ECR_REPO"
}

# Deploy application
deploy_application() {
    print_status "Deploying application to Kubernetes..."
    
    # Update Helm values with ECR repository
    ECR_REPO=$(terraform -chdir=terraform output -raw ecr_repository_url)
    
    helm upgrade --install $APP_NAME ./kubernetes/myapp \
        --namespace $NAMESPACE \
        --create-namespace \
        --set image.repository=$ECR_REPO \
        --set image.tag=latest \
        --set replicaCount=2 \
        --set service.type=LoadBalancer \
        --wait \
        --timeout=10m
    
    print_status "Application deployed successfully"
}

# Verify deployment
verify_deployment() {
    print_status "Verifying deployment..."
    
    # Check if pods are running
    kubectl get pods -n $NAMESPACE
    
    # Check service
    kubectl get svc -n $NAMESPACE
    
    # Get application URL
    print_status "Getting application URL..."
    
    # Wait for load balancer to be ready
    print_warning "Waiting for load balancer to be ready (this may take a few minutes)..."
    kubectl wait --for=condition=Ready --timeout=300s pod -l app.kubernetes.io/instance=$APP_NAME -n $NAMESPACE
    
    # Get external IP
    EXTERNAL_IP=""
    while [ -z $EXTERNAL_IP ]; do
        echo "Waiting for external IP..."
        EXTERNAL_IP=$(kubectl get svc $APP_NAME-myapp -n $NAMESPACE --template="{{range .status.loadBalancer.ingress}}{{.hostname}}{{end}}")
        [ -z "$EXTERNAL_IP" ] && sleep 10
    done
    
    print_status "Application is accessible at: http://$EXTERNAL_IP:8080"
}

# Health check
health_check() {
    print_status "Performing health check..."
    
    # Run health check similar to the existing healthcheck.sh
    kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- curl $APP_NAME-myapp:8080 -n $NAMESPACE
    
    if [ $? -eq 0 ]; then
        print_status "Health check passed - Application is healthy"
    else
        print_error "Health check failed"
        # Optionally rollback
        # helm rollback $APP_NAME -n $NAMESPACE
    fi
}

# Cleanup function
cleanup() {
    print_warning "Cleaning up resources..."
    cd terraform
    terraform destroy -auto-approve
    cd ..
    print_status "Resources cleaned up"
}

# Main deployment function
main() {
    case "${1:-deploy}" in
        "deploy")
            check_prerequisites
            init_terraform
            deploy_infrastructure
            configure_kubectl
            build_and_push_image
            deploy_application
            verify_deployment
            health_check
            print_status "🎉 Deployment completed successfully!"
            ;;
        "cleanup")
            cleanup
            ;;
        "build")
            build_and_push_image
            ;;
        "verify")
            verify_deployment
            health_check
            ;;
        *)
            echo "Usage: $0 {deploy|cleanup|build|verify}"
            echo "  deploy  - Full deployment (default)"
            echo "  cleanup - Destroy all resources"
            echo "  build   - Build and push image only"
            echo "  verify  - Verify existing deployment"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
