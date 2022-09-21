data "aws_availability_zones" "availability" {}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(split(",", join(",", var.private_subnets_cidrs_per_availability_zone)), count.index)
  availability_zone = data.aws_availability_zones.availability.names[count.index]

  tags = merge(
    local.common-tags,
    map(
      "Name", "${lower(var.project_name)}-${lower(var.environment)}-private-subnet-${count.index + 1}",
      "Description", "${lower(var.environment)} private subnet - ${count.index + 1}"
    )
  )
}


resource "aws_subnet" "public_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(split(",", join(",", var.public_subnets_cidrs_per_availability_zone)), count.index)
  availability_zone = data.aws_availability_zones.availability.names[count.index]

  tags = merge(
    local.common-tags,
    map(
      "Name", "${lower(var.project_name)}-${lower(var.environment)}-public-subnet-${count.index + 1}",
      "Description", "${lower(var.environment)} public subnet - ${count.index + 1}"
    )
  )
}