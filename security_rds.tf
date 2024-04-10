#Creating an rds security group
resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-clixx"

  vpc_id = aws_vpc.main.id
}

#declaring "http" security group rules for http
resource "aws_security_group_rule" "bast_http" {
    security_group_id        = aws_security_group.rds_sg.id
    description              = "Allows inbound traffic from the public subnet"
    type                     ="ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.bastion-sg.id
}

#declaring "http" security group rules for http
resource "aws_security_group_rule" "webpp_http" {
    security_group_id        = aws_security_group.rds_sg.id
    description              = "Allows inbound traffic from the public subnet"
    type                     ="ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.my_security_group.id
}



#declaring "http" security group rules for ssh
resource "aws_security_group_rule" "bast_ssh" {
    security_group_id        = aws_security_group.rds_sg.id
    description              = "Allows inbound traffic for SSH"
    type                     ="ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.bastion-sg.id
}

#declaring "http" security group rules for ssh
resource "aws_security_group_rule" "webapp_ssh" {
    security_group_id        = aws_security_group.rds_sg.id
    description              = "Allows inbound traffic for SSH"
    type                     ="ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.my_security_group.id
}



#declaring "http" security group rules for sql
resource "aws_security_group_rule" "bast_ingress_sql" {
security_group_id = aws_security_group.rds_sg.id

  type             = "ingress"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
  source_security_group_id = aws_security_group.bastion-sg.id
  }

#declaring "http" security group rules for sql
resource "aws_security_group_rule" "webb_ingress_sql" {
security_group_id = aws_security_group.rds_sg.id

  type             = "ingress"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
  source_security_group_id = aws_security_group.my_security_group.id
  }



#declaring "ingress" security group rules for ssh
resource "aws_security_group_rule" "bast_ingress_https" {
security_group_id = aws_security_group.rds_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  source_security_group_id = aws_security_group.bastion-sg.id
}

#declaring "ingress" security group rules for ssh
resource "aws_security_group_rule" "webb_ingress_https" {
security_group_id = aws_security_group.rds_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  source_security_group_id = aws_security_group.my_security_group.id
}

#declaring "ingress" security group rules for oracle
resource "aws_security_group_rule" "bast_ingress_oracle" {
security_group_id = aws_security_group.rds_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  source_security_group_id = aws_security_group.bastion-sg.id
}

#declaring "ingress" security group rules for oracle
resource "aws_security_group_rule" "webb_ingress_oracle" {
security_group_id = aws_security_group.rds_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  source_security_group_id = aws_security_group.my_security_group.id
}



#declaring "ingress" security group rules for icmp
resource "aws_security_group_rule" "bast_ingress_icmp" {
security_group_id = aws_security_group.rds_sg.id
 
  type              = "ingress"
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  source_security_group_id = aws_security_group.bastion-sg.id
}


#declaring "ingress" security group rules for icmp
resource "aws_security_group_rule" "webb_ingress_icmp" {
security_group_id = aws_security_group.rds_sg.id
 
  type              = "ingress"
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  source_security_group_id = aws_security_group.my_security_group.id
}




#declaring "egress" security group rules for egress
resource "aws_security_group_rule" "bast_egress_allow_all" {
  security_group_id = aws_security_group.rds_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  source_security_group_id = aws_security_group.bastion-sg.id
}

#declaring "egress" security group rules for ssh
resource "aws_security_group_rule" "webb_egress_allow_all" {
  security_group_id = aws_security_group.rds_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  source_security_group_id = aws_security_group.my_security_group.id
}

