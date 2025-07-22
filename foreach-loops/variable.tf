
variable "ami_id"  {

    type = string
    default = "ami-09c813fb71547fc4f"
  
}

variable "instance_type" {
    type = string
    default = "t3.micro"
}

variable "instance_names" {
    type = map
    default = {
        mongodb = "t3.small"
        redis = "t3.micro"
        mysql = "t3.small"
        rabbitmq = "t3.micro"
        catalogue = "t3.micro"
        user = "t3.micro"
        cart = "t3.micro"
        shipping = "t3.small"
        payment = "t3.micro"
        dispatch = "t3.micro"
        web = "t3.micro"

    }
}



# variable "sg-name" {
#     type = string
#     default = "allow-all-sg"
# }

# variable "sg-description" {
#     type = string
#     default = "Allow TLS inbound traffic"
# }       

# variable "vpc_id" {
#     type = string
#     default = ""  # Default to empty, can be set to a specific VPC ID if needed
# }

# variable "cidr_blocks" {
#     type = list(string)
#     default = ["0.0.0.0/0"]
# }

# variable "protocol" {
#     type = string
#     default = "tcp"
# }           

# variable "from_port" {
#     type = number
#     default = 0
# }   

# variable "to_port" {
#     type = number
#     default = 0
# }   

variable "zone_id" {
     type = string
     default = "Z06436571X1B9TSZB48VA"  # Default to empty, can be set to a specific Route53 zone ID if needed
 }

 variable "domain_name" {
     type = string
     default = "ravisripada.fun"  # Default domain name for the Route53 records
 }  