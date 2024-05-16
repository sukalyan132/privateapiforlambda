
data "aws_availability_zones" "available" {}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners     = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}
locals {
  ddb_table_name  = "claimsTable"
  env             = "dev"
  az1             = data.aws_availability_zones.available.names[0]
  az2             = data.aws_availability_zones.available.names[1]
  ami             = data.aws_ami.amazon_linux_2.id
}