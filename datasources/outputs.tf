# output "ami_id" {
#     value = data.aws_ami.rhel-9.id

# }

output "aws_ami_id" {
    value = data.aws_ami.amazon-linux-2.id

}

output "vpc_info" {
    value = data.aws_vpc.default
}