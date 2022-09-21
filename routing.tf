#------------------------------------------------------------------------------
# IGW
#------------------------------------------------------------------------------
resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    local.common-tags,
    map(
      "Name", "${lower(var.project_name)}-${lower(var.environment)}-main-igw",
      "Description", "Internet Gateway"
    )
  )
}

#------------------------------------------------------------------------------
# NAT Gateway
#------------------------------------------------------------------------------
resource "aws_eip" "nat"{}

resource "aws_nat_gateway" "main-natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public_subnet[0].id
  tags = merge(
    local.common-tags,
    map(
      "Name", "${lower(var.project_name)}-${lower(var.environment)}-natgw",
      "Description", "NAT Gateway"
    )
  )
}

#------------------------------------------------------------------------------
# Route Table
#------------------------------------------------------------------------------
