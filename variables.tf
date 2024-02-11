variable "aws_region" {
  default = "us-east-1"
  description = "aws region settings"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
  description = "vpc cidr block info"
}

variable "ami" {
  description = "The Amazon Machine Image ID to use for the instance"
  default     = "ami-079db87dc4c10ac91"
}

variable "instance_type" {
  description = "The type of instance to start"
  default     = "t2.micro"
}

variable "availability_zone" {
  description = "The availability zone in which to launch the instance"
  default     = "us-east-1a"
}

variable "key_name" {
  description = "The key pair to use for the instance"
  default     = "main-key"
}

variable "private_ip" {
  description = "The private IP address to associate with the instance in a VPC"
  default     = "10.0.0.50"
}

variable "private_ips" {
  description = "The private IP addresses to assign to the instance"
  type        = list(string)
  default     = ["10.0.0.50"]
}

variable "subnet_cidr_block" {
  description = "The CIDR block for the subnet"
  default     = "10.0.0.0/24"
}