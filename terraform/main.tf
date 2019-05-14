provider "google" {
    credentials  = "${file("../database_load.json")}"
    project      = "${var.project}"
}
resource "google_compute_instance" "master" {
    name         = "master"
    machine_type = "f1-micro"
    zone         = "${var.zone}"

    boot_disk {
        initialize_params {
            image = "master-image-lb"
        }
    }

    network_interface {
        network = "default"

        access_config {
            // Ephemeral IP
        }
    }
}

resource "google_compute_instance" "slave1" {
    name         = "slave1"
    machine_type = "f1-micro"
    zone         = "${var.zone}"

    boot_disk {
        initialize_params {
            image = "slave1"
        }
    }

    network_interface {
        network = "default"

        access_config {
            // Ephemeral IP
        }
    }
}

resource "google_compute_instance" "slave2" {
    name         = "slave2"
    machine_type = "f1-micro"
    zone         = "${var.zone}"

    boot_disk {
        initialize_params {
            image = "slave2"
        }
    }

    network_interface {
        network = "default"

        access_config {
            // Ephemeral IP
        }
    }
}

resource "google_compute_instance" "haproxy" {
    name         = "haproxy"
    machine_type = "f1-micro"
    zone         = "${var.zone}"

    boot_disk {
        initialize_params {
            image = "haproxy-image"
        }
    }

    network_interface {
        network    = "default"
        network_ip = "${var.haproxy_internal_ip}"

        access_config {
        nat_ip = "${var.haproxy_external_ip}"
        }
    }

}