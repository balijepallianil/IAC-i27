variable "bucket" {
  default = "i27_bucket_statefile"
}
variable "projectid" {
  default = "glass-approach-423807-a5"
}

variable "region" {
  default = "us-central1"
}

variable "vpc_name" {
    default = "i27-ecommerce-vpc"
  
}

variable "cidr" {
  default = "10.1.0.0/16"
}

variable "firewall_name" {
  default = "i27-firewall"
}

variable "ports" {
  default = [80, 8081, 8080, 9000, 22]
}

variable "instances" {
  default = {
    "jenkins-master" = {
        instance_type = "e2-medium"
        zone = "us-central1-a"
    }
    "jenkins-slave" = {
        instance_type = "e2-medium"
        zone = "us-central1-b"
    }
     "ansible" = {
        instance_type = "e2-medium"
        zone = "us-central1-a"
    }
  }
}

variable "vm_user" {
  default = "siva"
}


  