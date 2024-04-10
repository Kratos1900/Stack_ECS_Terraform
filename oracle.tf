# # Create Oracle RDS instance
# resource "aws_db_instance" "oracle_db" {
#   identifier             = "OracleDB"
#   allocated_storage      = 50
#   storage_type           = "gp2"
#   engine                 = "oracle-se2"
#   instance_class         = "db.t2.micro"
#   username               = "admin"
#   password               = "your_password" # Change to your desired password
#   subnet_group_name      = "OracleDBSubnetGroup"
#   publicly_accessible    = false
# }

# # Create RDS Subnet Group for Oracle Database
# resource "aws_db_subnet_group" "oracle_db_subnet_group" {
#   name       = "OracleDBSubnetGroup"
#   subnet_ids = [aws_subnet.private_subnets[3].id] # Fourth private subnet for Oracle DB
# }