locals {
  api_server_records = compact(var.api_server_lb)
  hosted_zone        = format("%s.%s", var.zone_prefix, var.main_domain)
  records            = [aws_route53_record.record, aws_route53_record.zone, aws_route53_zone.zone]
  zone_records       = list(local.hosted_zone, format("dex.%s", local.hosted_zone))
}
