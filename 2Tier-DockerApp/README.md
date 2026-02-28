# 2 Tier Docker App

A Flask web application with PostgreSQL database running on Docker and AWS ECS.

## Table of Contents

- [Overview](#overview)
- [Local Development](#local-development)
- [AWS ECR Deployment](#aws-ecr-deployment)
- [ECS Architecture](#ecs-architecture)
- [Infrastructure](#infrastructure)

## Overview

Transforms the previous 'EC2WebApp' project into containerized services with Docker Compose.

**Components:**
- Flask web application with dependencies
- PostgreSQL database with health checks
- Services configured with `docker-compose.yml`

## Local Development

### Prerequisites

- Docker & Docker Compose installed
- Python 3.13+
- AWS CLI configured (for ECR operations)

### Quick Start

1. **Build the image:**
   ```bash
   docker build -t webapp:1.0 .
   ```

2. **Run with Docker Compose:**
   ```bash
   docker-compose up -d
   ```

3. **Access the app:**
   - Web app: `http://localhost:5000`
   - Database: PostgreSQL on `localhost:5432`

4. **Stop containers:**
   ```bash
   docker-compose down
   ```

## AWS ECR Deployment

Push your image to AWS Elastic Container Registry.

**ECR Repository:** `628132821277.dkr.ecr.eu-north-1.amazonaws.com/benbo/webapp`

### Step-by-Step

1. **Authenticate with AWS ECR:**
   ```bash
   aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 628132821277.dkr.ecr.eu-north-1.amazonaws.com
   ```

2. **Tag your image with ECR URI:**
   ```bash
   docker tag webapp:1.0 628132821277.dkr.ecr.eu-north-1.amazonaws.com/benbo/webapp:1.0
   ```

3. **Push to ECR:**
   ```bash
   docker push 628132821277.dkr.ecr.eu-north-1.amazonaws.com/benbo/webapp:1.0
   ```

## ECS Architecture

Once your image is in ECR, deploy to AWS ECS.

### Key Components

| Component | Purpose |
|-----------|---------|
| **Cluster** | Logical grouping of resources (no storage itself) |
| **Task Definition** | Infrastructure blueprint for containers; defines roles, environment variables, logging, storage, and image source |
| **Service** | Manages deployment of tasks; configures subnets, load balancers, and desired task count |
| **Load Balancer** | Routes traffic to tasks; target group must be type **IP** (not instance) |

### Deployment Flow

1. Create a **Cluster**
2. Define a **Task Definition** (specify container image, CPU, memory, environment)
3. Create a **Service** in the cluster (set desired task count, subnets, load balancer)
4. Service automatically scales tasks based on desired count

## Infrastructure

![Infra Diagram](infra_diagram.png?raw=true "Infrastructure Diagram")



