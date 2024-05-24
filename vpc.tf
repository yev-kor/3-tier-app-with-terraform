#+++ AZs to use
data "aws_availability_zones" "available" {}

#+++ VPC Creating
resource "aws_vpc" "click_vpc" {
  cidr_block           = local.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "click_app_vpc"
  }
}

#+++ Front App Subnets
resource "aws_subnet" "front_app_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.click_vpc.id
  cidr_block              = local.front_subnet_cidr[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "front_app_public_subnet_${count.index + 1}"
  }
}

#+++ Back App Subnets
resource "aws_subnet" "back_app_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.click_vpc.id
  cidr_block              = local.back_subnet_cidr[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "back_app_private_subnet_${count.index + 1}"
  }
}

#+++ Redis Subnets
resource "aws_subnet" "redis_subnet" {
  count                   = 1
  vpc_id                  = aws_vpc.click_vpc.id
  cidr_block              = local.redis_subnet_cidr[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "redis_private_subnet_${count.index + 1}"
  }
}

#+++ VPC Internet Gateway
resource "aws_internet_gateway" "click_app_igw" {
  vpc_id = aws_vpc.click_vpc.id

  tags = {
    Name = "click_app_igw"
  }
}

#+++ EIP for NAT Gateway
resource "aws_eip" "nat_eip" {
  count  = 1
  domain = "vpc"

  tags = {
    Name = "nat_eip_${count.index + 1}"
  }
}

#+++ NAT Gateway for Back App Subnet Internet Access
resource "aws_nat_gateway" "click_app_nat" {
  count         = 1
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.front_app_subnet.*.id[count.index]

  depends_on = [aws_internet_gateway.click_app_igw]

  tags = {
    Name = "click_app_nat_${count.index + 1}"
  }
}

#+++ Private(Default) RT
resource "aws_default_route_table" "default_rt" {
  default_route_table_id = aws_vpc.click_vpc.default_route_table_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.click_app_nat[0].id
  }

  tags = {
    Name = "Click App Default RT"
  }
}

#+++ Public RT
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.click_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.click_app_igw.id
  }

  tags = {
    Name = "Click App Public RT"
  }
}

#+++ Private RT Associations for back app
resource "aws_route_table_association" "private_rt_assoc_1" {
  count          = 2
  subnet_id      = aws_subnet.back_app_subnet.*.id[count.index]
  route_table_id = aws_default_route_table.default_rt.id
}

#+++ Private RT Associations for redis
resource "aws_route_table_association" "private_rt_assoc_2" {
  count          = 1
  subnet_id      = aws_subnet.redis_subnet.*.id[count.index]
  route_table_id = aws_default_route_table.default_rt.id
}

#+++ Public RT Associations for front
resource "aws_route_table_association" "public_rt_assoc_1" {
  count          = 2
  subnet_id      = aws_subnet.front_app_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id
}

