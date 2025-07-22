resource "aws_instance" "web" {
    for_each = var.instance_names 
    ami = var.ami_id
    instance_type = each.value
    # vpc_security_group_ids = [aws_security_group.allow_all.id]

    tags = {
        Name = each.key
    }
}
# resource "aws_security_group" "allow_all" {
#   name        = var.sg-name
#   description = var.sg-description
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = var.protocol
#     cidr_blocks = var.cidr_blocks
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = var.cidr_blocks
#   }

#   tags = {
#     Name = "allow-all"
#   }
# }

# resource "aws_route53_record" "www" {
#     count = 11
#     zone_id = var.zone_id
#     name = "${var.instance_names[count.index]}.${var.domain_name}"
#     type = "A"
#     ttl = 1
#     records = [var.instance_names[count.index] == "web" ? aws_instance.web[count.index].public_ip : aws_instance.web[count.index].private_ip]
# }

resource "aws_route53_record" "www" {
    for_each = aws_instance.web 
    zone_id = var.zone_id
    name = "${each.key}.${var.domain_name}"
    type = "A"
    ttl = 1
    records = [each.key == "web" ? each.value.public_ip : each.value.private_ip]
    
  }