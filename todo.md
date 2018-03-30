# TODO:
## Application tasks
1. Check input from client
2. Add version to app
3. Add [multithread](http://rubylearning.com/satishtalim/ruby_socket_programming.htmlmultithread) 

## Deploy
1. Dockerized application     - 3hr
    ````
    docker build -t idemia-app .
    docker run -it --rm idemia-app
    ````
2. Provisioning
    - Create ECR repo
        ```bash
        aws ecr create-repository --repository-name idemia-app
        ```
        ```json
        {
            "repository": {
                "repositoryArn": "arn:aws:ecr:eu-west-1:XXXXXXXXXXXX:repository/idemia-app",
                "registryId": "XXXXXXXXXXXX",
                "repositoryName": "idemia-app",
                "repositoryUri": "XXXXXXXXXXXX.dkr.ecr.eu-west-1.amazonaws.com/idemia-app",
                "createdAt": 1522172700.0
            }
        }
        ```
    - Build and tag image - +1 = 4hrs
        ```bash
        # export AWS_ACCOUNT_ID='XXXXXXXXXXXX'
        export APP_VERSION=$(git describe --exact-match --abbrev=0)
        $(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
        docker build -t idemia-app:0.0.1 .
        docker tag idemia-app:$APP_VERSION $AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/idemia-app:$APP_VERSION
        docker push $AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/idemia-app:$APP_VERSION
        docker tag idemia-app:$APP_VERSION $AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/idemia-app:latest
        docker push $AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/idemia-app:latest
        ```
    - Create EC2 docker-compose env
    - Deploy app to ECS cluster
3. Provisioning with service healthcheck
4. Create an alert to send an email if health check fails
5. Document
