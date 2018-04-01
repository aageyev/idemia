# Deploy Idemia App (TCP daemon)

1. [Requirement](#requirement)
2. [Provisioning](#provisioning)
3. [Configuration](#configuration)
4. [Launching](#launching)
5. [Deploy](#deploy)

## Requirement <a name="requirement"></a>

To run this code you need:
* Ansible + boto3 on your workstation
* AWS account
* AWS_ACCESS_KEY and AWS_SECRET_KEY
* AWS ECR repository
* AWS IAM EC2 role to pull images from ECR


## Provisioning <a name="provisioning"></a>

### Configuration <a name="configuration"></a>

#### Edit ansible/inventory.ini
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

#### Set environment variables to access AWS

```bash
AWS_ACCESS_KEY='XXXXXXXXXXXXXXXXXXXX'
export $AWS_ACCESS_KEY
AWS_SECRET_KEY='XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
export $AWS_SECRET_KEY
```

### Launching <a name="launching"></a>

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

## Deploy <a name="deploy"></a>

Run playbook:
```bash
./deploy-app.yml
```
and enter $app_version and push 'Enter'.
And you'll run tasks...
1. Commit and push code to git repo
2. Create git tag with Application Version $app_ver
    ```bash
    git tag -a 0.0.2 -m "version 0.0.2"
    git push origin --tags
    ```
3. Login to ecr
   ```bash
   aws ecr get-login --region eu-west-2 --no-include-email
   ```
   copy and run stdout
4. Build docker image, tag it and push to ecr
   ```bash
   docker build -t idemia-app:0.0.2 .
   docker tag idemia-app:0.0.2 821302506864.dkr.ecr.eu-west-2.amazonaws.com/idemia-app:0.0.2
   docker tag idemia-app:0.0.2 821302506864.dkr.ecr.eu-west-2.amazonaws.com/idemia-app:latest
   docker push 821302506864.dkr.ecr.eu-west-2.amazonaws.com/idemia-app:0.0.2
   docker push 821302506864.dkr.ecr.eu-west-2.amazonaws.com/idemia-app:latest
   ```
5. Login to environment (according to deployment_id from config), navigate to $docker_compose_dir and run
   ```bash
   docker-compose stop; docker-compose pull; docker-compose up -d
   ```