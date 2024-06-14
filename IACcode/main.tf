

resource "google_compute_network" "tf_vpc" {
    name = var.vpc_name
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "tf-subnet" {
  name = "${var.vpc_name}-subnet"
  network = google_compute_network.tf_vpc.name
  region = var.region
  ip_cidr_range = var.cidr
}

resource "google_compute_firewall" "tf_allow_ports" {
  name = var.firewall_name
  network = google_compute_network.tf_vpc.name
dynamic "allow" {
    for_each = var.ports
    content {
      protocol = "tcp"
      ports = [allow.value]
    }
}
source_ranges = ["0.0.0.0/0"]
}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "local_file" "private_key" {
  content = tls_private_key.ssh-key.private_key_pem
  filename = "${path.module}/id_rsa"
}

resource "local_file" "public_key" {
    content = tls_private_key.ssh-key.public_key_openssh
    filename = "${path.module}/id_rsa.pub"
  
}
resource "google_compute_instance" "tf_intance" {
  for_each = var.instances
  name = each.key
  zone = each.value.zone
  machine_type = each.value.instance_type
  tags = [each.key]
  
  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_image.self_link
      size = 10
      type = "pd-balanced"
    }
  }
network_interface {
  access_config {
    network_tier = "PREMIUM"
  }
  network = google_compute_network.tf_vpc.name
  subnetwork = google_compute_subnetwork.tf-subnet.name
}

metadata = {
   ssh-keys= "${var.vm_user}:${tls_private_key.ssh-key.public_key_openssh}"
}
connection {
type = "ssh"
user = var.vm_user
host = self.network_interface[0].access_config[0].nat_ip
private_key = tls_private_key.ssh-key.private_key_pem
}

provisioner "file" {
  source = each.key ==  "ansible" ? "ansible.sh" : "other.sh"
  destination = each.key == "ansible" ? "/home/${var.vm_user}/ansible.sh" : "/home//${var.vm_user}/other.sh"
}

provisioner "remote-exec" {
  inline = [ 
    each.key == "ansible" ? "chmod +x /home/${var.vm_user}/ansible.sh" : "echo 'skip this command'"]
}
}

data "google_compute_image" "ubuntu_image" {
  family = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}