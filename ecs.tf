# Define the ECS cluster
resource "aws_ecs_cluster" "clixx_app_cluster" {
  name = "clixx-app-cluster"
}


################################################################################


# --- ECS Capacity Provider ---

resource "aws_ecs_capacity_provider" "main" {
  count = length(var.azs)
  name = "clixx-ecs-ec2-${count.index}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.my_asg.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}


#ECS Capacity Provider
resource "aws_ecs_cluster_capacity_providers" "main" {
  count = length(var.azs)
  cluster_name       = aws_ecs_cluster.clixx_app_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.main[count.index].name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main[count.index].name
    base              = 1
    weight            = 100
  }
}


################################################################################


# --- ECS Node Role ---

data "aws_iam_policy_document" "ecs_node_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_node_role" {
  name_prefix        = "clixx-ecs-node-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_node_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_policy" {
  role       = aws_iam_role.ecs_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_node" {
  name_prefix = "clixx-ecs-node-profile"
  path        = "/ecs/instance/"
  role        = aws_iam_role.ecs_node_role.name
}

################################################################################



# --- ECS Node SG ---

resource "aws_security_group" "ecs_node_sg" {
  name_prefix = "demo-ecs-node-sg-"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################################################################################





#Creating ECR repo 
resource "aws_ecr_repository" "clixx_app_repo" {
  name = "clixx-app-repo"
  force_delete = true
}

################################################################################


# --- ECS Task Role ---

data "aws_iam_policy_document" "ecs_task_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name_prefix        = "clixx-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role" "ecs_exec_role" {
  name_prefix        = "clixx-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_exec_role_policy" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

################################################################################


# --- Cloud Watch Logs ---

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/demo"
  retention_in_days = 14
}

################################################################################

# ECS Task Definition
resource "aws_ecs_task_definition" "clixx_app_task" {
  family                   = "clixx-app-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "clixx-app-container",
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
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "bridge"
}

# ECS Service
resource "aws_ecs_service" "clixx_app_service" {
  count           = length(var.azs)
  name            = "clixx-app-service${count.index}"
  cluster         = aws_ecs_cluster.clixx_app_cluster.id
  task_definition = aws_ecs_task_definition.clixx_app_task.arn
  desired_count   = 2
  launch_type     = "EC2"

  # network_configuration {
  #   subnets         = aws_subnet.clixx-prvt_subnet[*].id 
  #   security_groups = [aws_security_group.my_security_group.id, aws_security_group.bastion-sg.id]   
    
 

  }
