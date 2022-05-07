resource "google_container_cluster" "primary" {
  name                     = "primary"
  location                 = "us-east1-c"
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.main.id
  subnetwork               = google_compute_subnetwork.private.id


  addons_config {

    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  release_channel {
    channel = "REGULAR"
  }


  ip_allocation_policy {
   # cluster_secondary_range_name  = "k8s-pod-range"
   # services_secondary_range_name = "k8s-service-range"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "192.168.1.0/28"
  }

     master_authorized_networks_config {
       cidr_blocks {
       cidr_block   = "10.0.0.0/24"
         display_name = "private-subnet-w-jenkins"
       }
     }
}
