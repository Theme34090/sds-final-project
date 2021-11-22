# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 3.27"
#     }
#   }

#   required_version = ">= 0.14.9"
# }

# provider "aws" {
#   profile = "default"
#   region  = var.region
# }

# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name = "NextcloudVpc"
#   }
# }

# resource "aws_internet_gateway" "gw" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "NextcloudInternetGateway"
#   }
# }

# resource "aws_security_group" "allow_web" {
#   name        = "Nextcloud_allow_web"
#   description = "Allow port 80 inbound traffic"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description = "HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group" "allow_ssh" {
#   name        = "Nextcloud_allow_ssh"
#   description = "Allow port 80 inbound traffic"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group" "allow_mysql_subnet" {
#   name        = "Nextcloud_allow_mysql_subnet"
#   description = "Allow port 3306 inbound from private_2 subnet traffic"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description = "mysql"
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.3.0/24"]
#   }
# }

# resource "aws_security_group" "allow_all_outbound" {
#   name        = "Nextcloud_allow_all_outbound"
#   description = "Allow all outbound traffic"
#   vpc_id      = aws_vpc.main.id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # resource "aws_security_group" "allow_all" {
# #   name        = "Nextcloud_allow_all"
# #   description = "Allow all traffic"
# #   vpc_id      = aws_vpc.main.id

# #   ingress {
# #     description = "HTTP"
# #     from_port   = 80
# #     to_port     = 80
# #     protocol    = "tcp"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }
# #   ingress {
# #     description = "SSH"
# #     from_port   = 22
# #     to_port     = 22
# #     protocol    = "tcp"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }
# #   ingress {
# #     description = "MySQL"
# #     from_port   = 3306
# #     to_port     = 3306
# #     protocol    = "tcp"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }

# #   egress {
# #     from_port   = 0
# #     to_port     = 0
# #     protocol    = "-1"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }

# #   lifecycle {
# #     create_before_destroy = true
# #   }
# # }