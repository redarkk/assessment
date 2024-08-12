# assessment

## TO Run the Docker Image Locally Follow below steps - 

1)cd assessment

2)docker build -t assessment .

3)docker run -d -p 80:80 assessment

## Github Actions integrations is as Follows 

Every time theere is a commit the pipeline will build an image with latest tags


## To deploy the application to ECS below are the steps that are important 
1) provision ECS cluster and attatch neccessary roles, permission , VPC subnets , security gropups 

2) Create a ECR registry to push the laatest images 
3) Deploy the ECR image over to the ECS cluster.
