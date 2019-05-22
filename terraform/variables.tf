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

variable "master_external_ip" {
  type    = "string"
  default = "35.241.161.186"
}

variable "master_internal_ip" {
  type    = "string"
  default = "10.132.0.4"
}

variable "slave1_internal_ip" {
  type    = "string"
  default = "10.132.0.11"
}

variable "slave1_external_ip" {
  type    = "string"
  default = "34.76.177.210"
}

variable "slave2_internal_ip" {
  type    = "string"
  default = "10.132.0.12"
}

variable "slave2_external_ip" {
  type    = "string"
  default = "35.205.248.108"
}
