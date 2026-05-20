variable "vpc1_private_subnets" {
  type    = list(string)
  default = []
}

variable "vpc1_public_subnets" {
  type    = list(string)
  default = []
}

variable "vpc2_private_subnets" {
  type    = list(string)
  default = []
}

variable "vpc2_public_subnets" {
  type    = list(string)
  default = []
}

variable "vpc3_private_subnets" {
  type    = list(string)
  default = []
}

variable "vpc3_public_subnets" {
  type    = list(string)
  default = []
}

variable "azs" {
  type    = list(string)
  default = []
}

variable "region" {
  type    = string
  default = ""
}

variable "vpc4_public_subnets" {
  type    = list(string)
  default = []
}

variable "vpc4_private_subnets" {
  type    = list(string)
  default = []
}

variable "eks_cluster_version" {
  type    = string
  default = "1.31"
}