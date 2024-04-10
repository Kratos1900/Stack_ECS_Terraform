#Creating Security Group for Bastion server
resource "aws_security_group" "bastion-sg" {
  name        = "bastion_sg"
  description = "Security Group for the Bastion Server"
  vpc_id      = aws_vpc.main.id
}



#Creating inbound security rule for the Bastion Server
resource "aws_security_group_rule" "Bastion-HTTP-inbound" {
    security_group_id = aws_security_group.bastion-sg.id
    description       = "Allow inbound hhtp traffic to the Bastion server"
    type              = "ingress" 
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "Bastion-SSH-inbound" {
    security_group_id = aws_security_group.bastion-sg.id
    description       = "Allow inbound SSH traffic to the Bastion server"
    type              = "ingress" 
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "Bastion-HTTPS-inbound" {
    security_group_id = aws_security_group.bastion-sg.id
    description       = "Allow inbound SSH traffic to the Bastion server"
    type              = "ingress" 
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "Bastion-mysql-inbound" {
    security_group_id = aws_security_group.bastion-sg.id
    description       = "Allow inbound SSH traffic to the Bastion server"
    type              = "ingress" 
    from_port         = 3306
    to_port           = 3306
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "Bastion-icmp-inbound" {
    security_group_id =  aws_security_group.bastion-sg.id
    description       = "Allow inbound SSH traffic to the Bastion server"
    type              = "ingress" 
    from_port         = -1
    to_port           = -1
    protocol          = "icmp"
    cidr_blocks       = ["0.0.0.0/0"]

}



#Creating outbound security rule for the Bastion Server
resource "aws_security_group_rule" "Bastion-outbound" {
    security_group_id = aws_security_group.bastion-sg.id
    description       = "Allow all outbound traffic"
    type              = "egress" 
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]

}