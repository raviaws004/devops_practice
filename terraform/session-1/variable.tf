variable "image_id" {
    type = string
    default = "ami-09c813fb71547fc4f"
}

variable "instance_type" {
    type = string
    default = "t3.micro"
}

variable "sg_name" {
    type = string
    default = "allow-all-sg"
}

variable "sg_description" {
    type = string
    default = "Allow TLS inbound traffic"
}

variable "vpc_id" {
    type = string
    default = ""  # Default to empty, can be set to a specific VPC ID if needed
}

variable "cidr_blocks" {
    type = list (string)
    default = ["0.0.0.0/0"]
}

variable "protocol" {
    type = string
    default = "tcp"
}