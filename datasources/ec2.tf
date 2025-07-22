resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t3.micro"


  tags = {
    Name = "Data-source"
  }
}