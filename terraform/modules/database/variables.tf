variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "allow_traffic_from_sgs" {
  type = list(string)
}
