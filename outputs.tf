#outputs private ip address for web instances
output "web-internal" {
 value = google_compute_instance.web_instance[*].network_interface.0.network_ip
}

#outputs private ip address for database instance
output "db-internal" {
 value = google_compute_instance.database_instance.network_interface.0.network_ip
}
#outputs public ip address
output "lb_ip_address" {
  description = "The IP address of the load balancer."
  value       = google_compute_global_forwarding_rule.default.ip_address
}

#outputs public ip address for web instances
output "web-external" {
  value = google_compute_instance.web_instance[*].network_interface.0.access_config.0.nat_ip
}
#outputs public ip address for database instance
output "db-external" {
  value = google_compute_instance.database_instance.network_interface.0.access_config.0.nat_ip
}
