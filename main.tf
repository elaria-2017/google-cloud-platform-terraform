provider "google" {
  credentials = "${file("cred.json")}"
  project     = "elarya"
  region      = "us-east1"
}
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}
resource "google_compute_network" "main" {
  name                    = "main"
  auto_create_subnetworks = false
}

# Public Subnet
resource "google_compute_subnetwork" "public" {
  name          = "public"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-east1"
  network       = google_compute_network.main.id
}

# Private Subnet
resource "google_compute_subnetwork" "private" {
  name          = "private"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-east1"
  network       = google_compute_network.main.id
  private_ip_google_access = "true"


}

# Cloud Router
resource "google_compute_router" "router" {
  name    = "router"
  network = google_compute_network.main.id
  bgp {
    asn            = 64514
    advertise_mode = "CUSTOM"
  }
}

# NAT Gateway
resource "google_compute_router_nat" "nat" {
  name                               = "nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = "private"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

    resource "google_compute_instance" "vm_instance" {
      name         = "private-vm"
      machine_type = "f1-micro"
      zone = "us-east1-b"
      boot_disk {
        initialize_params {
          image = "ubuntu-os-cloud/ubuntu-2004-lts"
        }
      }    
      network_interface {       
        network = "main"
        subnetwork    = "private"
      }
    }
    resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
