# The GitHub module's Pages custom domain follows this record directly, so the
# Pages setting can't drift from the DNS record. Referencing .name (rather than
# name + zone) is deliberate: the Cloudflare provider returns it as the full
# FQDN (knight-strike.clo5de.info) after a refresh, so appending the zone would
# double it.
output "knight-strike-pages-fqdn" {
  description = "FQDN of the knight-strike GitHub Pages CNAME, for the GitHub module's Pages custom domain."
  value       = cloudflare_dns_record.knight-strike.name
}

output "clo5de-info-zone-id" {
  description = "Zone ID of the clo5de.info Cloudflare zone, for records managed outside this module (e.g. the root-level ACM DNS-validation record for PyFun)."
  value       = cloudflare_zone.clo5de-info.id
}
