#outputs private ip address
output "web-internal" {
 value = google_compute_instance.web_instance.network_interface.0.network_ip
}
output "db-internal" {
 value = google_compute_instance.database_instance.network_interface.0.network_ip
}
#outputs public ip address
output "web-external" {
  value = google_compute_instance.web_instance.network_interface.0.access_config.0.nat_ip
}
output "db-external" {
  value = google_compute_instance.database_instance.network_interface.0.access_config.0.nat_ip
}