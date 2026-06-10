<#
PowerShell helper to deploy `my-aws-website` to EC2.

Prerequisites:
- AWS CLI installed and configured (`aws configure`).
- PowerShell run from the `my-aws-website` directory.
- The script will create an S3 bucket (you choose name) and sync the current folder to it,
  then create a security group and an EC2 instance that pulls the site from S3 and serves via nginx.

This is a convenience script — review before running and ensure you understand AWS charges.
#>

param()

function Exec($cmd){
    Write-Host "> $cmd"
    $r = & cmd /c $cmd
    return $r
}

Write-Host "EC2 deploy helper — make sure AWS CLI is installed and configured." -ForegroundColor Cyan

$Region = Read-Host "Enter AWS region (default: us-east-1)"; if(-not $Region){$Region = 'us-east-1'}
$Bucket = Read-Host "Enter a globally-unique S3 bucket name to upload the site to"
if(-not $Bucket){ Write-Host "Bucket name is required." -ForegroundColor Red; exit 1 }

$KeyPair = Read-Host "Enter an EC2 key-pair name to use (must already exist in your account)"
if(-not $KeyPair){ Write-Host "Key pair name is required (for SSH)." -ForegroundColor Red; exit 1 }

$InstanceType = Read-Host "Enter instance type (default: t3.micro)"; if(-not $InstanceType){$InstanceType = 't3.micro'}

Write-Host "Creating S3 bucket and uploading site..." -ForegroundColor Green
Exec("aws s3 mb s3://$Bucket --region $Region") | Out-Null
Exec("aws s3 sync . s3://$Bucket --delete --region $Region") | Out-Null

Write-Host "Preparing user-data file for EC2..." -ForegroundColor Green
$UserDataTemplate = Join-Path -Path (Resolve-Path .) -ChildPath "deploy/user-data.sh"
$UserDataInstance = Join-Path -Path (Resolve-Path .) -ChildPath "deploy/user-data-ec2.sh"
if(-not (Test-Path $UserDataTemplate)){
    Write-Host "user-data template not found at $UserDataTemplate" -ForegroundColor Red; exit 1
}

(Get-Content $UserDataTemplate) -replace 'BUCKETNAME', $Bucket -replace 'REGIONNAME', $Region | Set-Content $UserDataInstance -NoNewline

Write-Host "Creating security group (opens port 22 and 80)..." -ForegroundColor Green
$sgName = "jishu-shop-sg-$(Get-Random)"
$sgJson = Exec("aws ec2 create-security-group --group-name $sgName --description 'jishu shop sg' --region $Region --output json")
$sg = ($sgJson | ConvertFrom-Json)
$sgId = $sg.GroupId
Exec("aws ec2 authorize-security-group-ingress --group-id $sgId --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $Region") | Out-Null
Exec("aws ec2 authorize-security-group-ingress --group-id $sgId --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $Region") | Out-Null

Write-Host "Resolving latest Amazon Linux 2 AMI via SSM..." -ForegroundColor Green
$ami = Exec("aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --region $Region --query Parameters[0].Value --output text").Trim()
Write-Host "Using AMI: $ami"

Write-Host "Launching EC2 instance..." -ForegroundColor Green
$runJson = Exec("aws ec2 run-instances --image-id $ami --count 1 --instance-type $InstanceType --key-name $KeyPair --security-group-ids $sgId --user-data file://$UserDataInstance --region $Region --output json")
$run = ($runJson | ConvertFrom-Json)
$instanceId = $run.Instances[0].InstanceId
Write-Host "Instance launched: $instanceId"

Write-Host "Waiting for instance to be in 'running' state..." -ForegroundColor Green
Exec("aws ec2 wait instance-running --instance-ids $instanceId --region $Region") | Out-Null

Write-Host "Fetching public DNS/IP..." -ForegroundColor Green
$desc = Exec("aws ec2 describe-instances --instance-ids $instanceId --region $Region --query 'Reservations[0].Instances[0].{PublicIp:PublicIpAddress,PublicDns:PublicDnsName}' --output json")
$info = ($desc | ConvertFrom-Json)

Write-Host "Deployment complete." -ForegroundColor Cyan
Write-Host "InstanceId: $instanceId"
Write-Host "Public IP: $($info.PublicIp)"
Write-Host "Public DNS: $($info.PublicDns)"

Write-Host "Open http://$($info.PublicIp) or http://$($info.PublicDns) in your browser." -ForegroundColor Yellow

Write-Host "Notes: the script created an S3 bucket and an EC2 instance; remember to clean up resources when finished to avoid charges." -ForegroundColor Magenta
