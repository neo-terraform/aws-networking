module "aws-network" {
  source       = "../"
  single_nat   = true
  project_name = "defi"
  vpc_cidr     = "192.168.0.0/16"
  environment  = "prod"

  region = "ap-southeast-1"

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

  common_tags = {
    "Project"          = "defi"
    "Platform"         = "AWS"
  }
}