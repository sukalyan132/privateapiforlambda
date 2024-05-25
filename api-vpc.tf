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

resource "aws_ec2_subnet_cidr_reservation" "private_sn_az1_rsv" {
  cidr_block       = "10.0.1.0/28"
  reservation_type = "explicit"
  subnet_id        = aws_subnet.private_sn_az1.id
}
resource "aws_ec2_subnet_cidr_reservation" "private_sn_az2_rsv" {
  cidr_block       = "10.0.2.0/28"
  reservation_type = "explicit"
  subnet_id        = aws_subnet.private_sn_az2.id
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

resource "aws_route_table" "private_rt_az1" {
  vpc_id = aws_vpc.api_vpc.id

  route {
    cidr_block = "172.128.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.api_client_vpc_peering.id
  }
  tags = {
    Name = "private_rt_az1"
  }
}

#  route table association between private_rt_az1 private_route_1 and private_sn_az1
resource "aws_route_table_association" "private_rta1_az1" {
  subnet_id      = aws_subnet.private_sn_az1.id
  route_table_id = aws_route_table.private_rt_az1.id
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

#  route table for private subnet az2
resource "aws_route_table" "private_rt_az2" {
  vpc_id = aws_vpc.api_vpc.id

  route {
    cidr_block = "172.128.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.api_client_vpc_peering.id
  }
  tags = {
    Name = "private_rt_az2"
  }
}

#  route table association for private subnet az2
resource "aws_route_table_association" "private_rta_az2" {
  subnet_id      = aws_subnet.private_sn_az2.id
  route_table_id = aws_route_table.private_rt_az2.id
}



#########################################
# VPC Peering with client VPC
#########################################

resource "aws_vpc_peering_connection" "api_client_vpc_peering" {
  vpc_id        = aws_vpc.api_vpc.id
  peer_vpc_id   = aws_vpc.client_vpc.id
  auto_accept   = true
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  requester {
    allow_remote_vpc_dns_resolution = true
  }
  tags = {
    Name = "api-client-vpc-peering",
    Side = "Requester"
  }
}


###########################################
# DNS resolution for private api endpoint
##########################################



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


