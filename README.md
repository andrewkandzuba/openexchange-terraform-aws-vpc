# Abstract

This repo contains Terraform (c) projects that automates a lot of routine operations while preparing for AWS CDA 2023.

# Prerequisites

- AWC CLI is installed and authenticated
- Terraform CLI is installed

# Projects
                                                                                         
- **vpc_no_lb**
  - Deploy EC2 cluster without any LB. Each EC2 instance is directly accessible via HTTP Layer 7 by its public ip. 


- **vpc_with_alb**
  - Deploy the cluster of EC2s with HTTPD accessible via HTTP Layer 7 ALB.

# Usage
## Stand Up
```bash
> cd <PROJECT DIR> 
> terraform init
> terraform plan -out=tf.plan
> terraform apply -auto-approve tf.plan
```
## Verify
-  **vpc_no_lb**
```bash
> aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text | xargs -I %s -- curl %s
```
Check if you can see `Hello, World!` messages

- **vpc_with_alb**
```bash
> aws elbv2 describe-load-balancers --query 'LoadBalancers[*].DNSName' \
    --output text | xargs -I %s -- curl -X GET -H 'Cache-Control: no-cache, no-store' %s 
```
Repeat the command and check if you can see `Hello, World!` messages from different hosts.

- **vpc_with_asg**
This module demonstrates how to launch the auto-scaling group inside the custom VPC and attach it to the ALB with PLAIN and TLS. 
```bash
> aws elbv2 describe-load-balancers --query 'LoadBalancers[*].DNSName' \
    --output text | xargs -I %s -- curl -X GET -H 'Cache-Control: no-cache, no-store' %s 
```
Check if you can see `Hello, World!` messages from different hosts.


## Tear Down 
```bash
> terraform destroy -auto-approve tf.plan
```

# Special Notes

1. AWS warns about the Self Signed ceriticate while deploying the HTTPS endpoint for ALB.