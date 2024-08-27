# Terraform Infrastructure Configuration

## Overview

This repository contains Terraform configuration files for deploying an infrastructure on AWS. The setup includes an ECS cluster with an Nginx service, an RDS instance, an S3 bucket, and associated networking components such as VPCs, subnets, and load balancers.

## Directory Structure

- `modules/`: Contains reusable Terraform modules for network setup, load balancing, compute resources, database, and storage.
- `main.tf`: Main Terraform configuration file that uses the modules to set up the infrastructure.

### Resources

1. **ECS Cluster**: Defines an ECS cluster for running containerized applications.
2. **ECS Task Definition**: Specifies the task definition for running Nginx in a Fargate task.
3. **Load Balancer**: An Application Load Balancer (ALB) is set up to route traffic to ECS services.
4. **ECS Service**: Manages the deployment of the Nginx container in the ECS cluster.
5. **Database**: Includes an RDS instance with PostgreSQL, along with security groups and subnet groups.
6. **Networking**: Configures VPC, public and private subnets, route tables, and NAT gateway.
7. **S3 Bucket**: Defines an S3 bucket for web app storage.
8. **IAM Roles**: Sets up IAM roles and policies for ECS tasks to access the S3 bucket.

### GitHub Actions

GitHub Actions are used to automate the deployment process. The workflow is defined in the `.github/workflows/deploy.yml` file. It includes steps for initializing Terraform, planning changes, and applying them based on the branch being pushed.

### Usage

#### Setup
Ensure you have Terraform installed and configured with access to AWS.

#### Initialize
Terraform: Run ```terraform init``` to initialize the working directory.

#### Plan
Run ```terraform plan``` to see the proposed changes.

#### Apply
Run ```terraform apply``` to apply the changes.

## Contributing
Feel free to open issues or submit pull requests if you have suggestions or improvements.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
