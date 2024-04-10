#Creating subnet group for RDS

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
   # Select subnets 9 and 10 from different availability zones
  subnet_ids = aws_subnet.RDS-prvt_subnet[*].id
 
  tags = {
    Name = "My DB Subnet Group"
  }
}   



#Creating the RDS database
resource "aws_db_instance" "clixx" {
  count             = length(var.azs)
  identifier        = "clixx-${count.index}"
  engine            = "mysql"
  instance_class    = "db.t2.micro"
  snapshot_identifier     = data.aws_db_snapshot.clixx_snapshot.id
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
  skip_final_snapshot = true 

  tags = {
    Name = "clixx-${count.index}"
  }

}






