provider "aws" {
    region = "eu-west-3"
}

variable "subnet1_cidr_block" {
  description = "subnet ip range"
}
variable "subnet2_cidr_block" {
  description = "subnet2 ip range"
}

resource "aws_vpc" "development_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "development_vpc"
  }
}

resource "aws_subnet" "dev_subnet_1" {
  vpc_id = aws_vpc.development_vpc.id
  cidr_block = var.subnet1_cidr_block
  availability_zone = "eu-west-3a"
  tags = {
    Name = "dev_subnet1"
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
    Name = "dev_subnet2"
  }
}

output "dev-vpc" {
    value = aws_vpc.development_vpc.id
  
}

output "dev-subnet1" {
  value = aws_subnet.dev_subnet_1.id
}

output "dev-subnet2" {
  value = aws_subnet.dev_subnet_2.id
}