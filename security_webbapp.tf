# Create the security for webapp.
resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "My Security Group"
  vpc_id      = aws_vpc.main.id  
 }
  
  
resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.my_security_group.id
  description = "Allow SSH traffic to the server from the bastion server"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  source_security_group_id = aws_security_group.bastion-sg.id
}

resource "aws_security_group_rule" "NFS" {
  security_group_id = aws_security_group.my_security_group.id
  description = "Allow NFS traffic from efs"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 2049
  to_port           = 2049
  source_security_group_id = aws_security_group.efs-sec.id
}

resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.my_security_group.id
  description = "Allow HTTP traffic to the server"
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.my_security_group.id
  description = "Allow HTTP traffic to the server"
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  source_security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "mysql" {
  security_group_id = aws_security_group.my_security_group.id
  description = "Allow mysql connection to the server"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
  source_security_group_id = aws_security_group.bastion-sg.id
}

resource "aws_security_group_rule" "oracle" {
  security_group_id = aws_security_group.my_security_group.id
  description = "Allow oracle connection to the server"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  source_security_group_id = aws_security_group.bastion-sg.id
}

resource "aws_security_group_rule" "icmp" {
  security_group_id = aws_security_group.my_security_group.id
  description = "Allow HTTP traffic to the server"
  type = "ingress"
  from_port = -1
  to_port = -1
  protocol = "icmp"
  source_security_group_id = aws_security_group.alb-sg.id
}


#Creating security rules for outgoing traffic from clixx app server

resource "aws_security_group_rule" "All-traffic" {
  security_group_id = aws_security_group.my_security_group.id
  description = "Allow all outbound traffic from the server"
  type              = "egress"
  protocol          = "-1" 
  from_port         = 0
  to_port           = 0
  source_security_group_id = aws_security_group.bastion-sg.id
}

