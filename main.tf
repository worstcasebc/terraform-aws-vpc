resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_classiclink   = var.enable_classiclink
  instance_tenancy     = var.instance_tenancy

  tags = {
    "Name" = var.name
  }
}

resource "aws_subnet" "public-subnet" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = format("public-subnet-%s", count.index)
  }
}

resource "aws_subnet" "private-subnet" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets[count.index]
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = format("private-subnet-%s", count.index)
  }
}

resource "aws_internet_gateway" "default-igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "default-igw"
  }
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.vpc.id

  route = [{
    cidr_block                = "0.0.0.0/0"
    egress_only_gateway_id    = null
    gateway_id                = aws_internet_gateway.default-igw.id
    instance_id               = null
    ipv6_cidr_block           = null
    local_gateway_id          = null
    nat_gateway_id            = null
    network_interface_id      = null
    transit_gateway_id        = null
    vpc_endpoint_id           = null
    vpc_peering_connection_id = null
  }]

  tags = {
    "Name" = "default-route"
  }
}

resource "aws_route_table_association" "rta-public-subnet" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.default.id
}

resource "aws_eip" "nat-gateway-ip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-gateway-ip.id
  subnet_id     = aws_subnet.public-subnet[0].id
  tags = {
    "Name" = "NATGateway"
  }
}

resource "aws_route_table" "nat-gateway" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    "Name" = "nat-route"
  }
}

resource "aws_route_table_association" "nat-gateway" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.nat-gateway.id
}

resource "aws_instance" "bastionhost" {
  count         = var.bastion_host ? 1 : 0
  ami           = "ami-0bd39c806c2335b95"
  instance_type = "t2.micro"
  key_name      = "mbp"
  subnet_id     = aws_subnet.public-subnet[0].id

  vpc_security_group_ids      = [aws_security_group.bastion[0].id]
  associate_public_ip_address = true

  tags = {
    "Name" = "bastionhost"
  }
}

resource "aws_security_group" "bastion" {
  count  = var.bastion_host ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [format("%s/32", chomp(data.http.icanhazip.body))]
  }
  tags = {
    "Name" = "bastionhost"
  }
}

