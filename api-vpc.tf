resource "aws_vpc" "api_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "api-vpc"
  }

}

resource "aws_subnet" "public_sn_az1" {
  vpc_id                  = aws_vpc.api_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = local.az1
  map_public_ip_on_launch = true
  tags = {
    Name = "public-sn-az1"
  }
}



resource "aws_subnet" "private_sn_az1" {
  vpc_id                  = aws_vpc.api_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "private-sn-az1"
  }
}


# private subnet for az2
resource "aws_subnet" "private_sn_az2" {
  vpc_id                  = aws_vpc.api_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = local.az2
  map_public_ip_on_launch = false
  tags = {
    Name = "private-sn-az2"
  }
}

##################################
# VPC Endpoint for private API
##################################

# vpc endpoint for the execute-api
resource "aws_vpc_endpoint" "execute_api_ep" {
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  vpc_id              = aws_vpc.api_vpc.id
  service_name        = "com.amazonaws.${var.region}.execute-api"
  security_group_ids  = [aws_security_group.execute_api_ep_sg.id]
  subnet_ids          = [aws_subnet.private_sn_az1.id, aws_subnet.private_sn_az2.id]
  tags = {
    Name = "execute-api-endpoint"
  }
}



resource "aws_vpc_endpoint_policy" "execute_api_ep_policy" {
  vpc_endpoint_id = aws_vpc_endpoint.execute_api_ep.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "execute-api:Invoke"
        ],
        "Resource" : "*"
      }
    ]
  })
}


