output api_server_fqdn { value = aws_route53_record.record.0.fqdn }
output dex_fqdn { value = aws_route53_record.record.1.fqdn }
output name_servers { value = aws_route53_zone.zone.name_servers }
output record { value = local.records }
output zone_id { value = aws_route53_zone.zone.zone_id }
output zone_record_name { value = aws_route53_record.zone.name }
