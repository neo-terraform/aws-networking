
#------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = merge(
    var.common_tags,
    tomap({
      "Name" = "${lower(var.project_name)}-${lower(var.environment)}-vpc",
      "Description" = "AWS VPC"
      }
    )
  )
}
#------------------------------------------------------------------------------
# Subnet
#------------------------------------------------------------------------------
data "aws_availability_zones" "available" {}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnets_cidrs_per_availability_zone)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(split(",", join(",", var.private_subnets_cidrs_per_availability_zone)), count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.common_tags,
    tomap({
      "Name" = "${lower(var.project_name)}-${lower(var.environment)}-private-subnet-${count.index + 1}",
      "Description" = "${lower(var.environment)} private subnet - ${count.index + 1}"
    }
    )
  )
}

resource "aws_subnet" "public_subnet" {
  count             = length(var.private_subnets_cidrs_per_availability_zone)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(split(",", join(",", var.public_subnets_cidrs_per_availability_zone)), count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.common_tags,
    tomap({
      "Name" = "${lower(var.project_name)}-${lower(var.environment)}-public-subnet-${count.index + 1}",
      "Description" = "${lower(var.environment)} public subnet - ${count.index + 1}"
    }
    )
  )
}

#------------------------------------------------------------------------------
# IGW
#------------------------------------------------------------------------------
resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.common_tags,
    tomap({
      "Name" = "${lower(var.project_name)}-${lower(var.environment)}-main-igw",
      "Description" = "Internet Gateway"
    }
    )
  )
}

#------------------------------------------------------------------------------
# NAT Gateway
#------------------------------------------------------------------------------
resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "main-natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags = merge(
    var.common_tags,
    tomap({
      "Name" = "${lower(var.project_name)}-${lower(var.environment)}-natgw",
      "Description" = "NAT Gateway"
    }
    )
  )
}

#------------------------------------------------------------------------------
# Route Table
#------------------------------------------------------------------------------
resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-igw.id
  }

  tags = merge(
    var.common_tags,
    tomap({
      "Name" = "${lower(var.project_name)}-${lower(var.environment)}-public-route-table",
      "Description" = "Public Route Table"
    }
    )
  )
}

resource "aws_route_table" "PrivateRouteTable" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main-natgw.id
  }

  tags = merge(
    var.common_tags,
    tomap({
      "Name" = "${lower(var.project_name)}-${lower(var.environment)}-private-route-table",
      "Description" = "Private Route Table"
    }
    )
  )
}

#------------------------------------------------------------------------------
# Route Table
#------------------------------------------------------------------------------
resource "aws_route_table_association" "route_Publicsubnet" {
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  count          = length(var.public_subnets_cidrs_per_availability_zone)
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "route_Privatesubnet" {
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  count          = length(var.private_subnets_cidrs_per_availability_zone)
  route_table_id = aws_route_table.PrivateRouteTable.id
}