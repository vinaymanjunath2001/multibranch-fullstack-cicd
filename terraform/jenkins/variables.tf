variable "region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "c7i-flex.large"
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
}

variable "key_name" {
  description = "EC2 Key pair name"
  type        = string
}
