# Define the ECS cluster
resource "aws_ecs_cluster" "clixx_app_cluster" {
  name = "clixx-app-cluster"
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
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_exec_role.arn
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "bridge"
  
 container_definitions = jsonencode([{
    name         = "app",
    image        = "${aws_ecr_repository.clixx_app_repo.repository_url}:latest",
    essential    = true,
    portMappings = [{ containerPort = 80, hostPort = 80 }],


    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-region"        = "us-west-1",
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name,
        "awslogs-stream-prefix" = "cliXX"
      }
    },
  }])

}

# ECS Service
resource "aws_ecs_service" "clixx_app_service" {
  count           = length(var.azs)
  name            = "clixx-app-service${count.index}"
  cluster         = aws_ecs_cluster.clixx_app_cluster.id
  task_definition = aws_ecs_task_definition.clixx_app_task.arn
  desired_count   = 2
  launch_type     = "EC2"

  force_new_deployment = true
  placement_constraints {
  type = "distinctInstance"
 }

  triggers = {
   redeployment = timestamp()
 }
    
 load_balancer {
    target_group_arn = aws_lb_target_group.ClixxTFTG.arn
    container_name   = "app"
    container_port   = 80
  }

  depends_on = [aws_autoscaling_group.my_asg]

  }
