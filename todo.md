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
        ````
        aws ecr create-repository --repository-name idemia-app
        ````
        ````
        {
            "repository": {
                "repositoryArn": "arn:aws:ecr:eu-west-1:821302506864:repository/idemia-app",
                "registryId": "821302506864",
                "repositoryName": "idemia-app",
                "repositoryUri": "821302506864.dkr.ecr.eu-west-1.amazonaws.com/idemia-app",
                "createdAt": 1522172700.0
            }
        }
        ````
    - Build and tag image
        ````
        export APP_VERSION='0.0.1'
        $(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
        docker build -t idemia-app:0.0.1 .
        docker tag idemia-app:$APP_VERSION 821302506864.dkr.ecr.eu-west-1.amazonaws.com/idemia-app:$APP_VERSION
        docker tag idemia-app:$APP_VERSION 821302506864.dkr.ecr.eu-west-1.amazonaws.com/idemia-app:latest
        
        ````
3. Provisioning with service healthcheck
4. Create an alert to send an email if health check fails
5. Document
