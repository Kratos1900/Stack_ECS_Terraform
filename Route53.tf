

#Data Source to get the domain name
data "aws_route53_zone" "dom_name" {
  name = var.rte53_hosted_zone
}

#Creating CNAME type record
resource "aws_route53_record" "stack_dns" {
  zone_id = data.aws_route53_zone.dom_name.zone_id
  name = var.record_name
  type = var.record_type
  ttl = var.record_ttl
  records = [aws_lb.CliXX-LB.dns_name]
}