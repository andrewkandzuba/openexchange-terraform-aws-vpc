# Abstract

This repo contains Terraform (c) project that automates a lot of routine operations from AWS CDA 2023.

# Prerequisites

- AWC CLI is installed and authenticated
- Terraform CLI is installed

# Usage 
     
## Deploy
```bash
> terraform plan -out=tf.plan
> terraform apply -auto-approve tf.plan
```

## Verify 

### EC2 Instances

**Note:** This does not work when a EC2 security group allow inbound HTTP(S) traffic from ALB only. 

```bash
> aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text | xargs -I %s -- curl %s
```
Check if you can see `Hello, World!` messages
   
## EC2 ALB

```bash
> aws elbv2 describe-load-balancers --query 'LoadBalancers[*].DNSName'  
    --output text | xargs -I %s -- curl -X GET -H 'Cache-Control: no-cache, no-store' %s 
```
Repeat the command and check if you can see `Hello, World!` messages from different hosts. 

## Destroy
```bash
> terraform destroy  -auto-approve
```
