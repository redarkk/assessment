#!/bin/bash

# Variables
CLUSTER_NAME="my-ecs-cluster"
SERVICE_NAME="my-web-app-service"
TASK_DEFINITION_NAME="my-web-app-task"
CONTAINER_NAME="assessment"
IMAGE_NAME="assessment:latest"
ECS_ROLE_NAME="ecsTaskExecutionRole"
ECR_REPOSITORY_NAME="my-web-app-repo"

# Step 1: Create an ECR Repository (if it doesn't exist)
aws ecr create-repository --repository-name $ECR_REPOSITORY_NAME

# Step 2: Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Step 3: Tag the Docker image for ECR
docker tag $IMAGE_NAME <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/$ECR_REPOSITORY_NAME:latest

# Step 4: Push the Docker image to ECR
docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/$ECR_REPOSITORY_NAME:latest

# Step 5: Create an ECS Cluster (if it doesn't exist)
aws ecs create-cluster --cluster-name $CLUSTER_NAME

# Step 6: Create an IAM role for ECS tasks (if it doesn't exist)
aws iam create-role --role-name $ECS_ROLE_NAME --assume-role-policy-document file://ecs-trust-policy.json
aws iam attach-role-policy --role-name $ECS_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# Step 7: Register the task definition
cat <<EOL > task-definition.json
{
  "family": "$TASK_DEFINITION_NAME",
  "networkMode": "awsvpc",
  "executionRoleArn": "arn:aws:iam::<AWS_ACCOUNT_ID>:role/$ECS_ROLE_NAME",
  "containerDefinitions": [
    {
      "name": "$CONTAINER_NAME",
      "image": "<AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/$ECR_REPOSITORY_NAME:latest",
      "essential": true,
      "memory": 512,
      "cpu": 256,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
  ],
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "cpu": "256",
  "memory": "512"
}
EOL

aws ecs register-task-definition --cli-input-json file://task-definition.json

# Step 8: Create or Update the ECS Service
aws ecs create-service \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE_NAME \
    --task-definition $TASK_DEFINITION_NAME \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[<SUBNET_ID>],securityGroups=[<SECURITY_GROUP_ID>],assignPublicIp=ENABLED}"

echo "Deployment to Amazon ECS is complete."
