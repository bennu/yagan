data aws_route53_zone main {
  name         = var.main_domain
  private_zone = var.main_private
}

resource aws_route53_zone zone {
  force_destroy = var.zone_force_destroy
  name          = local.hosted_zone
}

resource aws_route53_record zone {
  name    = local.hosted_zone
  records = aws_route53_zone.zone.name_servers
  ttl     = var.record_ttl
  type    = "NS"
  zone_id = data.aws_route53_zone.main.zone_id
}

resource aws_route53_record record {
  count   = length(local.zone_records)
  name    = element(local.zone_records, count.index)
  records = local.api_server_records
  ttl     = var.record_ttl
  type    = "A"
  zone_id = aws_route53_zone.zone.zone_id
}
