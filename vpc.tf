resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = merge(
    local.common-tags,
    map(
      "Name", "${lower(var.project_name)}-${lower(var.environment)}-vpc"
    )
  )
}