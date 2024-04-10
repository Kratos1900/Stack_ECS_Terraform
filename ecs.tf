#Creating ECR repo to store docker images
resource "aws_ecr_repository" "clixx_app_repo" {
  name = "clixx-app-repo"
}

# Null resource to build and push Docker image
resource "null_resource" "build_docker_image" {
  triggers = {
    always_run = "${timestamp()}"  ##This ensures the docker image is rebuilt and pushed to ECR whenever Terraform is applied
  }

  provisioner "local-exec" {
    command = <<EOF
      # Build the Docker image
      docker build -t ${aws_ecr_repository.clixx_app_repo.repository_url}:latest /var/www/html

      # Login to ECR
      aws ecr get-login-password --region ${var.AWS_REGION} | docker login --username AWS --password-stdin ${aws_ecr_repository.clixx_app_repo.repository_url}

      # Push the Docker image to ECR
      docker push ${aws_ecr_repository.clixx_app_repo.repository_url}:latest
    EOF
  }
}


# Define the ECS cluster
resource "aws_ecs_cluster" "clixx_app_cluster" {
  name = "clixx-app-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "clixx_app_task" {
  family                   = "clixx-app-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "web-app-container",
      "image": "${aws_ecr_repository.clixx_app_repo.repository_url}:latest",
      "cpu": 256,
      "memory": 512,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
  ]
  DEFINITION
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
}

# ECS Service
resource "aws_ecs_service" "clixx_app_service" {
  name            = "clixx-app-service"
  cluster         = aws_ecs_cluster.clixx_app_cluster.id
  task_definition = aws_ecs_task_definition.clixx_app_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = aws_subnet.clixx-prvt_subnet[*].id 
    security_groups = [aws_security_group.my_security_group.id, aws_security_group.bastion-sg.id]      
    assign_public_ip = true
  }
}