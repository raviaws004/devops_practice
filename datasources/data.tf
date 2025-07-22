data "aws_ami" "amazon-linux-2" {
    owners = ["amazon"]
    most_recent = true

    filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
   }   

    filter {
    name   = "root-device-type"
    values = ["ebs"]
   }

   filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
 
}


data "aws_vpc" "default" {
  default = true  
}

