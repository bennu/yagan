# Route53 subzone

Create a subzone from an existing hosted zone in Route53

```hcl
module "subzone" {
  source      = "./"
  main_domain = var.main_domain
  zone_domain = var.resource_name
}
```

|Variable|Description|Required|Value|
|---|---|---|---|
|`main_domain`|Domain to create the subzone from|X||
|`main_private`|Wether the main domain is private or not||`false`|
|`zone_prefixes`|Prefixes list for hosted zones to be created (e.g. `["dev", "qa"]`)|X||
|`zone_force_destroy`|Wether the subzone should force-destroyed upon destruction removing all records or not||`true`|
|`zone_record_ttl`|TTL for subzone NS record||`"30"`|
