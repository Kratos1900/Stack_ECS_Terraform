#--------------- Creating security group for EFS -----------------
resource "aws_security_group" "efs-sec" {
  vpc_id      = aws_vpc.main.id
  name        = "EFS-SG"
  description = "Security group for EFS"
}


#---------------- Creating inbound security rule for EFS ----------------
resource "aws_security_group_rule" "efs-inbound" {
    security_group_id        = aws_security_group.efs-sec.id
    description              = "Allows inbound traffic for efs"
    type                     ="ingress"
    from_port                = 2049
    to_port                  = 2049
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.my_security_group.id
}


#--------------Creating outbound security rule for EFS ---------------------
resource "aws_security_group_rule" "efs-outbound" {
  security_group_id          = aws_security_group.efs-sec.id
  description                = "Allows outbound traffic from efs"
  type                       = "egress"
  protocol                   = "tcp"
  from_port                  = 2049
  to_port                    = 2049
  cidr_blocks              = ["0.0.0.0/0"]

}