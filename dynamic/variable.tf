variable "ingress_rules" {
    default = [
        {
            description = "Allow Port 80"
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        },

        {
            description = "Allow Port 443"
            from_port   = 443
            to_port     = 443
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        },

        {
            description = "Allow Port 22"
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        },

        {
            description = "Allow Port 3306"
            from_port   = 3306
            to_port     = 3306
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }


    ]
    
}