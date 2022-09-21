module "aws-network" {
  source       = "../"
  name_prefix  = "test-aws-network"
  single_nat   = true
  project_name = "test-aws-network"
  vpc_cidr     = "192.168.0.0/16"
  environment  = "testing"

  availability_zones = [
    "ap-southeast-1a",
    "ap-southeast-2a"
  ]

  public_subnets_cidrs_per_availability_zone = [
    "192.168.0.0/24",
    "192.168.1.0/24",
  ]

  private_subnets_cidrs_per_availability_zone = [
    "192.168.16.0/20",
    "192.168.32.0/20",
  ]
}