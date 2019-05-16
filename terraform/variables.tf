variable "project" {
    type    = "string"
    default = "tech-infra"
}

variable "zone" {
    type    = "string"
    default = "europe-west1-b"
}

variable "region" {
  type    = "string"
  default = "europe-west1"
}

variable "haproxy_internal_ip" {
  type    = "string"
  default = "10.132.0.79"
}

variable "haproxy_external_ip" {
  type    = "string"
  default = "35.205.146.64"
}
