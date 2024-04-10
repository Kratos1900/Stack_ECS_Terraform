# variable "AWS_ACCESS_KEY" {}
# variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {}

variable "environment" {
  default = "dev"
}

variable "default_vpc_id" {
  default = "vpc-0705c8e7f3958f4fa"
}

variable "default_vpc" {
  default = "vpc-0705c8e7f3958f4fa"
}

variable "system" {
  default = "Retail Reporting"
}

variable "subsystem" {
  default = "CliXX"
}

variable "availability_zone" {
  type = list(string)
  default = [ "us-east-1c",
  "us-west-1c"
  ]
}
variable "availability_zone2" {
  default = "us-west-1c"
}


variable "subnets_cidrs" {
  type = list(string)
  default = [
    "172.31.0.0/20"
  ]
}
variable "subnet" {
  default="subnet-0f601263912635522"
}

variable "subnets" {
  default="subnet-06d32dcc18cf58ea5"
}

variable "default-subnets" {
  default = {
    subnet   = "subnet-0f601263912635522"
    subnets  = "subnet-06d32dcc18cf58ea5"
  }
}

variable "subnet_ids"{
  type = list(string)
  default = [
    "subnet-0f601263912635522",
    "subnet-06d32dcc18cf58ea5"
  ]
}


variable "stack_controls" {
  type = map(string)
  default = {
  ec2_create = "Y"
  rds_create = "N"
  }
}

variable "EC2_Components" {
  type = map(string)
  default = {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = "true"
    instance_type = "t2.medium"
  }
}

variable "EC2_autoscaling" {
  type = map(string)
  default = {
    min_size             = 2
    max_size             = 4
    desired_capacity     = 2
    health_check_type    = "EC2"
    health_check_grace_period = 30
  }
}



variable "subnets_cidrss" {
  type = list(string)
  default = [
    "172.31.16.0/20"
  ]
}


variable "instance_type" {
  default = "t2.medium"
}

variable "MOUNT_POINT"{
  default = "/var/www/html"
}

# variable "DB_NAME"{}
# variable "DB_USER" {}
# variable "DB_PASSWORD" {}



variable "file_system_id" {
  default="aws_efs_file_system.stack_efs.id"
}


variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "my_key.pub"
}

variable "OwnerEmail" {
  default = "orji3011@gmail.com"
}

variable "AMIS" {
	type = map(string)
	default = {
	us-east-1 = "ami-stack-5.0"
	us-west-2 = "ami-06b94666"
	eu-west-1 = "ami-844e0bf7"
  }
}


# variable "public_subnet_cidrs" {
#  type        = list(string)
#  description = "Public Subnet CIDR values"
#  default     = ["10.0.2.0/23", "10.0.4.0/23"] #####################
# }
 
# variable "private_subnet_cidrs" {
#  type        = list(string)
#  description = "Private Subnet CIDR values"
#  default     = ["10.0.20.0/26", "10.0.21.0/26", "10.0.18.0/26", 
#  "10.0.19.0/26", "10.0.16.0/24", "10.0.17.0/24", 
#  "10.0.0.0/24", "10.0.1.0/24", "10.0.8.0/22", "10.0.12.0/22"] ###################
# }


# # Define a map variable that maps CIDRs to corresponding subnet IDs
# variable "subnet_cidr_mapping" {
#   type = map(string)
#   default = {
#     "10.0.20.0/26"  = "subnet-1" 
#     "10.0.21.0/26"  = "subnet-2"  
#     "10.0.18.0/26"  = "subnet-3"
#     "10.0.19.0/26"  = "subnet-4" 
#     "10.0.16.0/24"  = "subnet-5"
#     "10.0.17.0/24"  = "subnet-6"
#     "10.0.0.0/24"   = "subnet-7"
#     "10.0.1.0/24"   = "subnet-8"
#     "10.0.8.0/22"   = "subnet-9"
#     "10.0.12.0/22"  = "subnet-10"  
#   }
# }

variable "Bastion-pub-subnet-cidrs" {
  type = list(string)
  default = [
    "10.0.2.0/23", "10.0.4.0/23"
  ]
}


variable "clixx-prvt-subnet-cidrs" {
  type = list(string)
  default = [
    "10.0.0.0/24", "10.0.1.0/24"
  ]
}


variable "RDS-prvt-subnet-cidrs"{
  type = list(string)
  default = [
    "10.0.8.0/22", "10.0.12.0/22"
  ]
}

variable "Oracle-prvt-subnet-cidrs" {
  type = list(string)
  default = [
    "10.0.16.0/24", "10.0.17.0/24"
  ]
}

variable "Java-prvt-subnet-cidrs" {
  type = list(string)
  default = [
    "10.0.20.0/26", "10.0.21.0/26"
  ]
}

variable "Xtra-prvt-subnet-cidrs" {
  type = list(string)
  default = [
    "10.0.18.0/26", "10.0.19.0/26"
  ]
}



variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-west-1a", "us-west-1c"]
}



# Define EBS Volume
variable "ebs_volumes" {
    description = "EBS volumes that need to be created"
    type   = list(object({
        size = number
        type = string
    }))
    default = [{
      size = 30
      type = "gp2"
    },
    {
        size = 30
        type ="gp2"
    },
    
    {
        size = 30
        type ="gp2"
    },

    {
        size = 30
        type ="gp2"
    },
    
    {
        size = 30
        type ="gp2"
    }
  ]
}



variable "ingress_rules" {
  description = "Map of ingress rules"
  type        = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = {
    ssh = { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    NFS = { from_port = 2049, to_port = 2049, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    Mysql_Aurora = { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    http = { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
    https      = { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    oracle-RDS = { from_port = 1521, to_port = 1521, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
  }
}

variable "egress_rules" {
  description = "Map of egress rules"
  type        = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = {
    Alltraffic = { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] },
    outbound   = { from_port = 2049, to_port = 2049, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  }
}


variable "rte53_hosted_zone" {
default = "stack-charles.com"
}

variable "record_name" {
default = "www.dev.clixx"
}


variable "record_type" {
default = "CNAME"
}

variable "record_ttl" {
default = "300"
}













