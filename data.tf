#Data source for ami
data "aws_ami" "stack_ami" {
  owners     = ["self"]
  name_regex = "^ami-stack-5.*"
  most_recent = true      #Gets the most recent ami after update
  filter {
    name   = "name"
    values = ["ami-stack-5.*"]
  }
}


# Getting the VPC
data "aws_vpc" "default_vpc" {
  default = true
}

# Getting the subnet info
data "aws_subnets" "default-subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}


data "aws_autoscaling_groups" "my_asg" {
  names = [aws_autoscaling_group.my_asg.name]
}


#Data source for subnets
data "aws_subnets" "stack_sub" {    #pulls a list of subnets. You can loop through it or print it out.
  filter {
    name   = "vpc-id"
    values = [var.default_vpc_id]
  }
}

#Data source for subnets
data "aws_subnet" "stack_sub" {
  for_each = toset(data.aws_subnets.stack_sub.ids)
  id       = each.value
}

# Data source to get the snapshot identifier
data "aws_db_snapshot" "clixx_snapshot" {
  db_instance_identifier = "wordpressdbclixx-ecs"
  snapshot_type          = "manual" 
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "clixx_creds"
 }

 data "aws_secretsmanager_secret" "ami" {
  name = "ecs_id"
}
