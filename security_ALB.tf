# Creating a security group for the listener
resource "aws_security_group" "alb-sg" {
  name        = "Clixx_LB_SG"
  vpc_id      = aws_vpc.main.id  
  # Allow inbound HTTP requests
 
 dynamic "ingress" {
    for_each = var.ingress_rules

    content {
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules

    content {
      from_port   = egress.value["from_port"]
      to_port     = egress.value["to_port"]
      protocol    = egress.value["protocol"]
      cidr_blocks = egress.value["cidr_blocks"]
    }
  }
}