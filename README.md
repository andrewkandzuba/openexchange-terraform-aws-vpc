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
```bash
> aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
 --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text | | xargs -I %s -- echo %s
```
Check if you can see `Hello, World!` messages

## Destroy
```bash
> terraform destroy  -auto-approve
```
