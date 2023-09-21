provider "aws" {
    region = "eu-west-3"
}

variable "vpc_cid_block" {
  
}

variable "subnet_cidr_block" {
  
}

variable "env_prefix" {
  
}

variable "my_ip" {
  
}

variable "subnet1_cidr_block" {
  description = "subnet ip range"
}
variable "subnet2_cidr_block" {
  description = "subnet2 ip range"
}

resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cid_block
  tags = {
    Name = "${var.env_prefix}_vpc"
  }
}

resource "aws_subnet" "dev_subnet_1" {
  vpc_id = aws_vpc.myapp_vpc.id
  cidr_block = var.subnet1_cidr_block
  availability_zone = "eu-west-3a"
  tags = {
    Name = "${var.env_prefix}_subnet1"
  }
}

data  "aws_vpc" "existing_vpc" {
    default = true
}

resource "aws_subnet" "dev_subnet_2" {
  vpc_id = data.aws_vpc.existing_vpc.id
  cidr_block = var.subnet2_cidr_block
  availability_zone = "eu-west-3a"
  tags = {
    Name = "${var.env_prefix}_subnet2"
  }
}

resource "aws_internet_gateway" "myapp_internet_gateway" {
  vpc_id = aws_vpc.myapp_vpc.id
  tags = {
    Name = "${var.env_prefix}_internet_gateway"
  }
}

resource "aws_ec2_carrier_gateway" "myapp_carrier_gateway" {
  vpc_id = aws_vpc.myapp_vpc.id

  tags = {
    Name = "${var.env_prefix}_carrier-gateway"
  }
}

# resource "aws_vpc_endpoint" "s3" {
#   vpc_id       = aws_vpc.myapp_vpc.id
#   service_name = "com.amazonaws.us-west-2.s3"

#   tags = {
#     Environment = "test"
#   }
# }

resource "aws_egress_only_internet_gateway" "example" {
  vpc_id = aws_vpc.myapp_vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "myapp_route_table" {
  vpc_id = aws_vpc.myapp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.myapp_internet_gateway.id}"
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = "${aws_egress_only_internet_gateway.example.id}"
  }

  depends_on = [aws_internet_gateway.myapp_internet_gateway]
  tags = {
    Name = "${var.env_prefix}_route_table"
  }
}


resource "aws_route_table_association" "a-rtb-subnet1" {
  subnet_id = aws_subnet.dev_subnet_1.id
  route_table_id = aws_route_table.myapp_route_table.id
}


# resource "aws_route_table_association" "a-rtb-subnet2" {
#   subnet_id = aws_subnet.dev_subnet_2.id
#   route_table_id = aws_route_table.myapp_route_table.id
# }


resource "aws_security_group" "myapp_sg" {
  name = "myapp-sg"
  vpc_id = aws_vpc.myapp_vpc.id

  ingress =[{
    from_port = 22
    to_port = 22 
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
    ipv6_cidr_blocks = ["::/0"]
    description = "SSH"
    prefix_list_ids = []
    security_groups = []
    self = false 
  },{
    from_port = 8080
    to_port = 8080 
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "SSH"
    prefix_list_ids = []
    security_groups = []
    self = false 
  }]

  egress =  [{
    from_port = 0
    to_port = 0 
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "SSH"
    prefix_list_ids = []
    security_groups = []
    self = false 
  } ]

  tags = {
    Name = "${var.env_prefix}_sg"
  }
}




output "dev-vpc" {
    value = aws_vpc.myapp_vpc.id
  
}

output "dev-subnet1" {
  value = aws_subnet.dev_subnet_1.id
}

output "dev-subnet2" {
  value = aws_subnet.dev_subnet_2.id
}