#Bastion Server creation
resource "aws_instance" "bastion_server" {
  count                  =  length(var.azs)
  ami                    =  data.aws_secretsmanager_secret.ami.secret_string
  instance_type          =  var.EC2_Components["instance_type"]
  subnet_id              =  aws_subnet.Bastion-pub_subnet[count.index].id
  associate_public_ip_address =  true
  key_name               = aws_key_pair.Stack_KP.key_name
  security_groups        = [aws_security_group.my_security_group.id] #############

  tags = {
    Name = "BastionServer ${count.index + 1}"
  }
}

