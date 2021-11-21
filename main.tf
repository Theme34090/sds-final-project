terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "NextcloudVpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "NextcloudInternetGateway"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "Nextcloud_allow_all"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "NextcloudAppServerPublicSubnet"
  }
}

resource "aws_route_table" "public_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "NextcloudRouteTable"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_1.id
}

resource "aws_network_interface" "app_server" {
  subnet_id       = aws_subnet.public_1.id
  private_ips     = ["10.0.1.10"]
  security_groups = [aws_security_group.allow_all.id]

  tags = {
    Name = "NextcloudAppServerNetworkInterface"
  }
}

resource "aws_eip" "app_server" {
  vpc                       = true
  network_interface         = aws_network_interface.app_server.id
  associate_with_private_ip = "10.0.1.10"

  tags = {
    Name = "NextcloudPublicEip"
  }
}

resource "aws_instance" "app_server" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  key_name                    = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.app_server.id
    device_index         = 0
  }

  depends_on = [aws_eip.app_server, aws_iam_access_key.s3, aws_s3_bucket.bucket]

  # user_data = <<-EOF
  #   echo "${data.template_file.app_storage_config.rendered}" > /tmp/storage.config.php
  #   echo "${file("./app-server/nextcloud.conf")}" > /tmp/nextcloud.conf
  #   ${data.template_file.setup_app.rendered}
  #   EOF

  user_data = <<-EOF
    #!/bin/bash
    echo "${file("${path.module}/app-server/nextcloud.conf")}" > /tmp/nextcloud.conf
    echo "${templatefile("${path.module}/app-server/storage.config.php", {
      bucket_name        = var.bucket_name,
      region             = aws_s3_bucket.bucket.region,
      s3_key             = aws_iam_access_key.s3.id,
      s3_secret          = aws_iam_access_key.s3.secret,
    })}" > /tmp/storage.config.php
    echo '${templatefile("${path.module}/app-server/setup.sh", {
      database_name = var.database_name,
      database_user = var.database_user,
      database_pass = var.database_pass,
      admin_user    = var.admin_user,
      admin_pass    = var.admin_pass,
      public_ip     = aws_eip.app_server.public_ip,
      s3_key        = aws_iam_access_key.s3.id,
      s3_secret     = aws_iam_access_key.s3.secret
    })}' > /tmp/setup.sh
    chmod +x /tmp/setup.sh
    /tmp/setup.sh
    EOF

  tags = {
    Name = "NextcloudAppServer"
  }
}
