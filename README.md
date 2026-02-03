# AWS Multi-VPC Infrastructure with VPC Lattice

[![Terraform](https://img.shields.io/badge/Terraform-1.0%2B-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A production-ready Terraform configuration for deploying a multi-VPC AWS infrastructure with Amazon VPC Lattice for cross-VPC service networking. This infrastructure supports ECS containerized applications, Lambda functions, and EC2 Auto Scaling groups across isolated VPCs with centralized service discovery.

## 🏗️ Architecture Overview

This configuration deploys a comprehensive multi-VPC architecture featuring:

- **3 VPCs** with isolated network boundaries (10.1.0.0/16, 10.2.0.0/16, 10.3.0.0/16)
- **VPC Lattice Service Network** for cross-VPC service communication
- **ECS Fargate** deployment in VPC1 with Application Load Balancer
- **Lambda Function** deployment in VPC2
- **EC2 Auto Scaling Group** deployment in VPC3 with Application Load Balancer
- **Centralized service discovery** without VPC peering or Transit Gateway

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    VPC Lattice Service Network                  │
│                     (Cross-VPC Connectivity)                    │
└─────────────────────────────────────────────────────────────────┘
         │                      │                      │
         ▼                      ▼                      ▼
┌────────────────┐    ┌────────────────┐    ┌────────────────┐
│     VPC 1      │    │     VPC 2      │    │     VPC 3      │
│  10.1.0.0/16   │    │  10.2.0.0/16   │    │  10.3.0.0/16   │
│                │    │                │    │                │
│  ┌──────────┐  │    │  ┌──────────┐  │    │  ┌──────────┐  │
│  │   ALB    │  │    │  │  Lambda  │  │    │  │   ALB    │  │
│  └─────┬────┘  │    │  │ Function │  │    │  └─────┬────┘  │
│        │       │    │  └──────────┘  │    │        │       │
│  ┌─────▼────┐  │    │                │    │  ┌─────▼────┐  │
│  │   ECS    │  │    │  Service 2     │    │  │   ASG    │  │
│  │ Fargate  │  │    │                │    │  │  (EC2)   │  │
│  └──────────┘  │    │                │    │  └──────────┘  │
│                │    │                │    │                │
│  Service 1     │    │                │    │  Service 3     │
└────────────────┘    └────────────────┘    └────────────────┘
```

## 📋 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Module Structure](#-module-structure)
- [Getting Started](#-getting-started)
- [Configuration](#-configuration)
- [Deployment](#-deployment)
- [Services](#-services)
- [Security](#-security)
- [Monitoring & Logging](#-monitoring--logging)
- [Cleanup](#-cleanup)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

## ✨ Features

### Network Infrastructure
- **Multi-AZ VPC Setup**: High availability across multiple availability zones
- **NAT Gateways**: One per AZ for production-grade resilience
- **Internet Gateways**: Public subnet internet connectivity
- **DNS Support**: Enabled DNS hostnames and resolution
- **Security Groups**: Layered security with least-privilege access

### Compute Services
- **ECS Fargate**: Serverless container orchestration
- **Lambda Functions**: Event-driven serverless compute
- **Auto Scaling Groups**: Self-healing EC2 fleet with dynamic scaling
- **Application Load Balancers**: Traffic distribution with health checks

### Container & Image Management
- **Amazon ECR**: Private container registry with lifecycle policies
- **Automated Build & Push**: CI/CD integration scripts
- **Image Scanning**: Security vulnerability detection (configurable)
- **Immutable Tags**: Production-grade image versioning

### Service Networking
- **VPC Lattice**: Simplified service-to-service communication
- **Cross-VPC Routing**: No peering or Transit Gateway required
- **Service Discovery**: Built-in DNS and service mesh capabilities
- **IAM-Based Authentication**: Secure service access control

### Observability
- **ALB Access Logs**: Stored in S3 with encryption
- **CloudWatch Integration**: Metrics and monitoring
- **Health Checks**: Automated service health monitoring

## 🔧 Prerequisites

Before deploying this infrastructure, ensure you have:

### Required Tools
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) >= 2.0
- [Docker](https://www.docker.com/) (for container builds)
- [Git](https://git-scm.com/)

### AWS Requirements
- AWS Account with appropriate permissions
- AWS CLI configured with credentials
- IAM permissions for:
  - VPC management
  - EC2, ECS, Lambda
  - VPC Lattice
  - S3, ECR, IAM
  - CloudWatch Logs

### Configuration Files
- SSH key pair named `madmaxkeypair` (or update `key_name` variable)
- Application source code in `../src/` directory
- User data script at `../scripts/user_data.sh`

## 📁 Module Structure

```
.
├── main.tf                          # Root configuration
├── variables.tf                     # Input variables
├── outputs.tf                       # Output values
├── terraform.tfvars                 # Variable values
├── modules/
│   ├── vpc/                         # VPC module
│   ├── security-groups/             # Security group module
│   ├── ecr/                         # Container registry module
│   ├── iam/                         # IAM role/policy module
│   ├── ecs/                         # ECS service module
│   ├── load_balancer/               # ALB module
│   ├── lambda/                      # Lambda function module
│   ├── launch_template/             # EC2 launch template module
│   └── auto_scaling_group/          # ASG module
├── src/
│   ├── ecr-build-push.sh           # Container build script
│   └── nodeapp/                    # Application source
└── scripts/
    └── user_data.sh                # EC2 bootstrap script
```

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd <repository-directory>
```

### 2. Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter your default region (e.g., us-east-1)
```

### 3. Update Variables

Create or modify `terraform.tfvars`:

```hcl
region = "us-east-1"

azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

# VPC 1 Subnets
vpc1_public_subnets  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
vpc1_private_subnets = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]

# VPC 2 Subnets
vpc2_public_subnets  = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
vpc2_private_subnets = ["10.2.11.0/24", "10.2.12.0/24", "10.2.13.0/24"]

# VPC 3 Subnets
vpc3_public_subnets  = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]
vpc3_private_subnets = ["10.3.11.0/24", "10.3.12.0/24", "10.3.13.0/24"]
```

### 4. Create Required Scripts

Ensure your `user_data.sh` script exists:

```bash
#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker

# Add your application startup logic
docker run -d -p 8080:80 your-app:latest
```

### 5. Prepare Application Code

Place your application code in the `../src/nodeapp/` directory with a Dockerfile.

## ⚙️ Configuration

### VPC Configuration

Each VPC is configured with:
- **CIDR Block**: Non-overlapping ranges (10.1.0.0/16, 10.2.0.0/16, 10.3.0.0/16)
- **Subnets**: 3 public and 3 private subnets across availability zones
- **NAT Gateways**: One per AZ for high availability
- **Internet Gateway**: For public subnet internet access

### Security Groups

| Security Group | Purpose | Ingress | Egress |
|---------------|---------|---------|--------|
| `lattice-sg` | VPC Lattice endpoints | HTTP (80), All TCP (0) from 0.0.0.0/0 | All traffic |
| `ecs-lb-sg` | ECS Load Balancer | HTTP (80) from 0.0.0.0/0 | All traffic |
| `ecs-sg` | ECS Tasks | Port 8080 from ALB SG | All traffic |
| `lambda-sg` | Lambda Functions | None | All traffic |
| `ec2-lb-sg` | EC2 Load Balancer | HTTP (80) from 0.0.0.0/0 | All traffic |
| `ec2-asg-sg` | EC2 Instances | Port 8080 from ALB SG | All traffic |

### Auto Scaling Configuration

```hcl
min_size                  = 3
max_size                  = 50
desired_capacity          = 3
health_check_grace_period = 300
health_check_type         = "ELB"
```

### ECR Lifecycle Policy

- Keeps last 10 tagged images (prefix: "v")
- Deletes untagged images older than 7 days

## 📦 Deployment

### Initialize Terraform

```bash
terraform init
```

### Plan Deployment

```bash
terraform plan -out=tfplan
```

Review the plan carefully before applying.

### Apply Configuration

```bash
terraform apply tfplan
```

Or for interactive approval:

```bash
terraform apply
```

### Deployment Time

Expected deployment time: **15-25 minutes**

Components are created in order based on dependencies. Monitor progress in the terminal.

## 🌐 Services

### Service 1: ECS Fargate (VPC 1)

- **Type**: Containerized application on ECS Fargate
- **Access**: Via Application Load Balancer
- **Port**: 8080 (internal), 80 (external)
- **Scaling**: Auto-scaling enabled
- **Health Check**: HTTP on port 8080

**Access the service:**
```bash
# Get ALB DNS name
terraform output ecs_alb_dns_name

# Test endpoint
curl http://<alb-dns-name>
```

### Service 2: Lambda Function (VPC 2)

- **Type**: Serverless function
- **Runtime**: Node.js (configurable)
- **VPC**: Attached to VPC 2 private subnets
- **Access**: Via VPC Lattice
- **Invocation**: Event-driven or Lattice HTTP

**Invoke function:**
```bash
aws lambda invoke \
  --function-name <function-name> \
  --payload '{}' \
  response.json
```

### Service 3: EC2 Auto Scaling (VPC 3)

- **Type**: EC2 instances in Auto Scaling Group
- **Access**: Via Application Load Balancer
- **Instance Type**: t2.micro
- **Min/Max/Desired**: 3/50/3
- **Port**: 8080 (internal), 80 (external)

**Access the service:**
```bash
# Get ALB DNS name
terraform output ec2_alb_dns_name

# Test endpoint
curl http://<alb-dns-name>
```

### VPC Lattice Service Network

Enables cross-VPC communication without peering:

```bash
# Service 1 can call Service 2
curl http://service2.lattice-network/api/data

# Service 3 can call Service 1
curl http://service1.lattice-network/health
```

## 🔒 Security

### Network Security

- **Private Subnets**: All compute resources in private subnets
- **NAT Gateways**: Outbound internet access without exposing instances
- **Security Groups**: Stateful firewall rules
- **NACLs**: Additional network layer protection (configurable)

### IAM Security

- **Least Privilege**: Minimal permissions for each service
- **Execution Roles**: Separate roles for ECS tasks and Lambda functions
- **Instance Profiles**: EC2 instances with limited S3 access
- **Service-to-Service Auth**: VPC Lattice IAM-based authentication

### Data Security

- **S3 Encryption**: ALB logs encrypted at rest
- **ECR Encryption**: Container images encrypted
- **Secrets Management**: Use AWS Secrets Manager for sensitive data (recommended)

### Security Recommendations

1. **Enable VPC Flow Logs** for network monitoring
2. **Implement WAF** on ALBs for web application firewall protection
3. **Use Secrets Manager** for database credentials and API keys
4. **Enable GuardDuty** for threat detection
5. **Implement AWS Config** for compliance monitoring
6. **Rotate IAM credentials** regularly
7. **Enable MFA** for AWS account access

## 📊 Monitoring & Logging

### CloudWatch Metrics

Monitor key metrics:
- ECS CPU/Memory utilization
- ALB request count and latency
- Lambda invocations and errors
- ASG instance health
- VPC Lattice connection metrics

### Access Logs

ALB access logs are stored in S3 buckets:
- `ecs_lb_logs_bucket`: ECS ALB logs
- `ec2_lb_logs_bucket`: EC2 ALB logs

**Query logs:**
```bash
aws s3 ls s3://<bucket-name>/AWSLogs/
aws s3 cp s3://<bucket-name>/AWSLogs/<account-id>/elasticloadbalancing/<region>/<date>/ . --recursive
```

### CloudWatch Log Groups

- `/aws/ecs/nodeapp-cluster`: ECS task logs
- `/aws/lambda/<function-name>`: Lambda execution logs

**View logs:**
```bash
aws logs tail /aws/ecs/nodeapp-cluster --follow
```

## 🧹 Cleanup

### Destroy Infrastructure

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy
```

### Important Notes

1. **S3 Buckets**: May need to be emptied before destruction
2. **ECR Images**: Delete images manually if `force_delete = false`
3. **VPC Dependencies**: Ensure all ENIs are detached
4. **State File**: Backup `terraform.tfstate` before destroying

### Manual Cleanup Steps

If `terraform destroy` fails:

```bash
# Empty S3 buckets
aws s3 rm s3://<bucket-name> --recursive

# Delete ECR images
aws ecr batch-delete-image \
  --repository-name nodeapp-registry \
  --image-ids imageTag=latest

# Remove VPC Lattice associations manually if needed
aws vpc-lattice delete-service-network-vpc-association \
  --service-network-vpc-association-identifier <id>
```

## 🔍 Troubleshooting

### Common Issues

#### ECS Tasks Not Starting

**Symptoms**: Tasks remain in PENDING state
**Causes**:
- Insufficient ENIs in private subnets
- IAM role missing permissions
- ECR image pull failure

**Solutions**:
```bash
# Check ECS task logs
aws ecs describe-tasks --cluster nodeapp-cluster --tasks <task-id>

# Verify IAM role
aws iam get-role --role-name ecs-task-execution-role

# Test ECR access
aws ecr get-login-password | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com
```

#### Auto Scaling Group Unhealthy

**Symptoms**: Instances fail health checks
**Causes**:
- Application not listening on port 8080
- Security group blocking ALB health checks
- User data script errors

**Solutions**:
```bash
# Check instance logs
aws ec2 get-console-output --instance-id <instance-id>

# Verify security group rules
aws ec2 describe-security-groups --group-ids <sg-id>

# Test health check endpoint
curl http://<instance-private-ip>:8080/
```

#### VPC Lattice Connection Issues

**Symptoms**: Cross-VPC service calls fail
**Causes**:
- Security group blocking Lattice traffic
- IAM policy missing permissions
- Target group unhealthy

**Solutions**:
```bash
# Check Lattice service status
aws vpc-lattice get-service --service-identifier <service-id>

# Verify target group health
aws vpc-lattice list-targets --target-group-identifier <tg-id>

# Check IAM policy
aws iam get-policy-version --policy-arn <arn> --version-id <version>
```

#### Lambda Function Timeout

**Symptoms**: Lambda invocations timeout
**Causes**:
- VPC NAT Gateway configuration
- Security group egress rules
- Function timeout too low

**Solutions**:
```bash
# Increase timeout
aws lambda update-function-configuration \
  --function-name <name> \
  --timeout 60

# Check VPC configuration
aws lambda get-function-configuration --function-name <name>
```

### Debug Commands

```bash
# View Terraform state
terraform state list
terraform state show <resource>

# Validate configuration
terraform validate

# Check resource dependencies
terraform graph | dot -Tsvg > graph.svg

# Enable debug logging
export TF_LOG=DEBUG
terraform apply
```

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Terraform best practices
- Update documentation for any changes
- Test changes in a development environment first
- Use meaningful commit messages
- Add comments for complex logic

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- AWS VPC Lattice documentation
- Terraform AWS Provider documentation
- AWS Well-Architected Framework

## 📞 Support

For issues and questions:
- **Issues**: Open an issue on GitHub
- **Discussions**: Use GitHub Discussions
- **Security**: Report security issues privately

## 🗺️ Roadmap

- [ ] Add SSL/TLS termination at ALBs
- [ ] Implement AWS WAF rules
- [ ] Add VPC Flow Logs
- [ ] Integrate with AWS Secrets Manager
- [ ] Add CI/CD pipeline examples
- [ ] Implement multi-region deployment
- [ ] Add cost optimization recommendations
- [ ] Create Grafana dashboards

---

**Note**: This is a production-ready template. Review and customize security settings, instance types, and scaling parameters based on your specific requirements before deploying to production.
