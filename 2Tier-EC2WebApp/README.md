# 2 Tier Static Web App on EC2

Build upon the previosu project 'EC2WebApp'
Adds a Postgres DB hosted in AWS that can be written and read from using the app

Moved the EC2 instances and DB instance to private subnets

Used AWS Secrets Manager to store DB credentials, this involved attaching a policy to the launch template for authentication.