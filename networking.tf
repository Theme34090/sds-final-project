# app server public subnet

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
  security_groups = [aws_security_group.allow_web.id, aws_security_group.allow_ssh.id, aws_security_group.allow_all_outbound.id]

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

# db NAT private subnet

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "NextcloudDbServerPrivateSubnet"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "NextcloudNatEip"
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id
  depends_on    = [aws_internet_gateway.gw]

  tags = {
    Name = "NextcloudNatGw"
  }
}

resource "aws_route_table" "nat_private_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw.id
  }

  tags = {
    Name = "NextcloudDbServerToNatRouteTable"
  }
}

resource "aws_route_table_association" "nat_private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.nat_private_1.id
}

resource "aws_network_interface" "db_server" {
  subnet_id       = aws_subnet.private_1.id
  private_ips     = ["10.0.2.10"]
  security_groups = [aws_security_group.allow_all_outbound.id]

  tags = {
    Name = "NextcloudDbServerNetworkInterface"
  }
}

# app db subnet

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "NextcloudAppDbPrivateSubnet"
  }
}

resource "aws_network_interface" "private_2_db" {
  subnet_id       = aws_subnet.private_2.id
  private_ips     = ["10.0.3.10"]
  security_groups = [aws_security_group.allow_mysql_subnet.id]

  tags = {
    Name = "NextcloudDbServerNetworkInterface"
  }
}

resource "aws_network_interface" "private_2_app" {
  subnet_id       = aws_subnet.private_2.id
  private_ips     = ["10.0.3.11"]
  security_groups = [aws_security_group.allow_all_outbound.id]

  tags = {
    Name = "NextcloudAppServerNetworkInterface"
  }
}