# How to deploy Idemia App

## Requirement

To provision environment and deploy application you need
* Ansible + boto3 on your workstation
* AWS account
* AWS_ACCESS_KEY and AWS_SECRET_KEY
* AWS ECR repository
* AWS IAM EC2 role to pull images from ECR


## Provision environment

### Configuration
Edit ansible/inventory.ini
and set all variable in [all:vars] section.
You need to provide at least: 
* ecr repository url 
* ec2 region 
* Ubuntu 16.04 AMI for selected region
* ec2 zone
* ec2_ssh_key_pair
* path to private ssh key

```ini
[all:vars]
# name
deployment_id=idemia

# access to ec2 instance
ansible_ssh_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/a2-eu-west-2-1.pem

# EC2 settings
ec2_ssh_key_pair=a2-eu-west-2-1
ec2_region=eu-west-2
ec2_ami=ami-941e04f0
ec2_zone=eu-west-2a
ec2_instance_type=t2.micro
ec2_instance_profile=idemia

# docker-compose
app_ecr_url=821302506864.dkr.ecr.eu-west-2.amazonaws.com/idemia-app
docker_compose_dir=/opt/idemia

# application
idemia_app_port=1235

```   

### Launch environment

Navigate to ./ansible directory and run:
```bash
./env-provision.yml
```
This set of plays:
* Create EC2 Security Group
* EC2 Instance
* Install latest docker-ce and docker-compose on EC2 instance
* Generate docker-compose.yml file
* Run App using docker-compose
* Ensure application up and running
* Create route53 health check
* Create create alarm SNS topic

## Deploy application
