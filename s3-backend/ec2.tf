resource "aws_instance" "web" {
    count = 11 # Using count to create multiple instances
    ami = var.ami_id
    instance_type = var.instance_names[count.index] == "mongodb" || var.instance_names[count.index] == "mysql" || var.instance_names[count.index] == "shipping" ? "t3.small" : "t3.micro"
    vpc_security_group_ids = [aws_security_group.allow_all.id]

    tags = {
        Name = var.instance_names[count.index] # Using count.index to assign a unique name from the list
    }
}

resource "aws_security_group" "allow_all" {
  name        = var.sg-name
  description = var.sg-description
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = var.protocol
    cidr_blocks = var.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_blocks
  }

  tags = {
    Name = "allow-all"
  }
}

resource "aws_route53_record" "www" {
    count = 11
    zone_id = var.zone_id
    name = "${var.instance_names[count.index]}.${var.domain_name}"
    type = "A"
    ttl = 1
    records = [var.instance_names[count.index] == "web" ? aws_instance.web[count.index].public_ip : aws_instance.web[count.index].private_ip]
}

