# EC2 Deployment Helper — Instructions

This file describes the helper scripts in `deploy/` used to deploy the static site to an EC2 instance.

Files:
- `ec2-deploy.ps1` — PowerShell script that:
  - creates an S3 bucket (you provide the name) and `aws s3 sync` the current folder into it
  - creates a security group (opens TCP/22 and TCP/80)
  - launches an EC2 instance (Amazon Linux 2) with `user-data` that installs `nginx` and syncs from S3

- `user-data.sh` — template executed on first boot. The deploy script substitutes `BUCKETNAME` and `REGIONNAME` values.

Prerequisites:
- Install and configure the AWS CLI: `aws configure` (access key, secret, default region)
- Have an EC2 key-pair already created in the AWS console (you'll pass the key-pair name to the script)
- Run PowerShell from the `my-aws-website` directory

Quick run (PowerShell):
```powershell
cd 'D:\Python Chaptor 1\my-aws-website'
.\deploy\ec2-deploy.ps1
```

Follow prompts for region, S3 bucket name (must be globally unique), and the existing key-pair name.

Notes & cleanup:
- Review the script before running — it will create AWS resources that may incur charges.
- To remove resources: terminate the EC2 instance, delete the security group (if not in use), and remove the S3 bucket contents and the bucket.
