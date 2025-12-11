terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

#variables for project location and zone
provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

#VPC network
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

#firewall rule to allow ssh
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web", "db"]
}

#firewall rule to allow http and https
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-https"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

#firewall rule to allow icmp
resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

#firewall rule to allow db traffic
resource "google_compute_firewall" "allow_db" {
  name    = "allow-db"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_tags = ["web"]
  target_tags = ["db"]
}

#service account for VMs
resource "google_service_account" "vm_sa" {
  account_id   = "vm-wiki-sa"
  display_name = "VM Instance Service Account"
}

#persistent disk for backup
resource "google_compute_disk" "db_backup_disk" {
  name = "db-backup"
  type = "pd-balanced"
  zone = var.zone
  size = 10
}
#first VM instance for database
resource "google_compute_instance" "database_instance" {
  name         = "db-instance"
  machine_type = "e2-medium"
  tags         = ["db"]
  allow_stopping_for_update =  true


 boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }
  #attaches disk to vm
  attached_disk {
    source      = google_compute_disk.db_backup_disk.self_link
    device_name = "db-backup"
  }
  
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }

  #attaches SA to vm
  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["cloud-platform"]
  }
}

#second VM instance for mediawiki
 resource "google_compute_instance" "web_instance" {
  name         = "web-instance"
  machine_type = "e2-medium"
  tags         = ["web"]
  allow_stopping_for_update =  true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }
  
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }

  metadata = {
    google-ops-agent-policy = "{\"agentRules\":[{\"type\":\"ops-agent\",\"version\":\"latest\",\"packageState\":\"installed\"}]}"
  }
}
