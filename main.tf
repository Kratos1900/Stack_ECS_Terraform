
locals {
  clixx_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
 }

locals {
  ecs_id = jsondecode(
    data.aws_secretsmanager_secret_version.ecs_id.secret_string
  )
 }


### Declare Key Pair
resource "aws_key_pair" "Stack_KP" {
  key_name   = "stackkp90"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}



# Define EFS
resource "aws_efs_file_system" "stack_efs" {
  creation_token = "stack_efs"

  tags = {
      Name ="stack_efs"
  } 
}

# Define mount target for EFS
resource "aws_efs_mount_target" "stack_efs" {
  count = length(var.azs)
  file_system_id  =  aws_efs_file_system.stack_efs.id
  subnet_id       = aws_subnet.clixx-prvt_subnet[count.index].id  
  security_groups = [aws_security_group.efs-sec.id]
}



#Creating a load balancer
resource "aws_lb" "CliXX-LB" {
  name = "ClixxAppLB"
  load_balancer_type = "application"
  subnets = aws_subnet.Bastion-pub_subnet[*].id
  security_groups = [aws_security_group.alb-sg.id, aws_security_group.my_security_group.id]
}

#Creating listener rule
resource "aws_lb_listener" "CliXX-LBlistener" {
  load_balancer_arn = aws_lb.CliXX-LB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service Unavailable"
      status_code  = "503"
    }
  }
}


 
# Define a health check for the target group
resource "aws_lb_target_group" "ClixxTFTG" {
  name = "Clixx-TF-TG"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id

  health_check {
    path = "/"
    interval            = 30  # Check every 30 seconds
    timeout             = 5   # Timeout after 5 seconds
    healthy_threshold   = 2   # Require 2 successful checks for an instance to be considered healthy
    unhealthy_threshold = 2   # Mark an instance as unhealthy after 2 consecutive failed checks
    matcher             = "200-399"  # HTTP status codes indicating a healthy instance
 }
}


# Creating a listener rule 
resource "aws_lb_listener_rule" "lb_listner_rule" {
  listener_arn = aws_lb_listener.CliXX-LBlistener.arn
  priority = 100
  condition {
    path_pattern {
      values = [ "*" ]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ClixxTFTG.arn
  }
}


################################################################################ 

#Creating Autoscaling group  and launching instances
resource "aws_launch_configuration" "appserver" {
  name                 = "appserver"
  image_id             = local.ecs_id.image_id
  instance_type        = var.EC2_Components["instance_type"]
  security_groups      = [aws_security_group.my_security_group.id, aws_security_group.bastion-sg.id]
  user_data            = data.template_file.bootstrap.rendered
  key_name             = aws_key_pair.Stack_KP.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_type           = var.EC2_Components["volume_type"]
    volume_size           = var.EC2_Components["volume_size"]
    delete_on_termination = var.EC2_Components["delete_on_termination"]
    encrypted             = var.EC2_Components["encrypted"]
  }

# Define block device mappings for additional EBS volumes
  dynamic "ebs_block_device" {
    for_each = var.ebs_volumes

    content {
      device_name           = "/dev/sd${element(tolist(["b", "c", "d", "e", "f", "g"]), ebs_block_device.key)}"
      volume_size           = ebs_block_device.value.size
      volume_type           = ebs_block_device.value.type
      delete_on_termination = true
    }
  }
}


resource "aws_autoscaling_group" "my_asg" {
  name                      = "my-asg"
  launch_configuration      = aws_launch_configuration.appserver.name
  min_size                  = 2
  max_size                  = 2
  desired_capacity          = 2
  vpc_zone_identifier       = aws_subnet.clixx-prvt_subnet[*].id
  termination_policies      = ["OldestInstance"]
  target_group_arns         = [aws_lb_target_group.ClixxTFTG.arn]

  tag {
    key                 = "Name"
    value               = "Clixx-app-ecs"
    propagate_at_launch = true
  }
}

################################################################################



# --- ECS Launch Template ---

# data "aws_ssm_parameter" "ecs_node_ami" {
#   name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
# }

# resource "aws_launch_template" "ecs_ec2" {
#   name_prefix            = "clixx-ecs-ec2-"
#   image_id               = data.aws_secretsmanager_secret_version.ami.secret_string
#   instance_type          = var.EC2_Components["instance_type"]
#   vpc_security_group_ids = [aws_security_group.my_security_group.id, aws_security_group.bastion-sg.id]

#   iam_instance_profile { arn = aws_iam_instance_profile.ecs_node.arn }
#   monitoring { enabled = true }

#   user_data = base64encode(<<-EOF
#       #!/bin/bash
#       echo ECS_CLUSTER=${aws_ecs_cluster.clixx_app_cluster.name} >> /etc/ecs/ecs.config;
#     EOF
#   )
# }

# ################################################################################
# # --- ECS ASG ---

# resource "aws_autoscaling_group" "my_asg" {
#   name_prefix               = "clixx-ecs-asg-"
#   vpc_zone_identifier       = aws_subnet.clixx-prvt_subnet[*].id
#   min_size                  = 2
#   max_size                  = 4
#   health_check_grace_period = 0
#   health_check_type         = "EC2"
#   protect_from_scale_in     = false

#   launch_template {
#     id      = aws_launch_template.ecs_ec2.id
#     version = "$Latest"
#   }

#   tag {
#     key                 = "Name"
#     value               = "clixx-ecs-cluster"
#     propagate_at_launch = true
#   }

#   tag {
#     key                 = "AmazonECSManaged"
#     value               = ""
#     propagate_at_launch = true
#   }
# }