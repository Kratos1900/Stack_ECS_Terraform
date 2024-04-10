#Data source for output
output "subnet_ids" {
  #  value = [for s in data.aws_subnet.stack_subnets : s.cidr_block]
  value = [for s in data.aws_subnet.stack_sub : s.id]
  # value = [for s in data.aws_subnet.stack_sub : s.availability_zone]
  #value = [for s in data.aws_subnet.stack_sub : element(split("-", s.availability_zone), 2)]
}

output "alb_dns_name"  {
  value = aws_lb.CliXX-LB.dns_name
  description = "This is the domain name of the load balancer"
}

output "ebs_volume_count" {
  value = length(var.ebs_volumes)
}

output "aws_instance_count" {
  value = length(aws_launch_configuration.appserver)
}

#Retrieving RDS Endpoint
output "RDS_ENDPOINT" {
  value = aws_db_instance.clixx.*.endpoint
}