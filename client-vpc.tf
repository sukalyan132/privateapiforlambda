resource "aws_vpc" "client_vpc" {
    cidr_block = "172.128.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "client-vpc"
    }
}


resource "aws_subnet" "client_private_sn_az1" {
    vpc_id                 = aws_vpc.client_vpc.id
    cidr_block             = "172.128.1.0/24"
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = false

    tags = {
        Name = "client-private-subnet-az1"
    }
  
}

resource "aws_route_table" "client_private_rt_az1" {
    vpc_id = aws_vpc.client_vpc.id

    route {
        cidr_block = "10.0.0.0/16"
        vpc_peering_connection_id = aws_vpc_peering_connection.api_client_vpc_peering.id
    }

    tags = {
        Name = "client-private-rt-az1"
    }
  
}

resource "aws_subnet" "client_private_sn_az2" {
    vpc_id                 = aws_vpc.client_vpc.id
    cidr_block             = "172.128.2.0/24"
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = false

    tags = {
        Name = "client-private-subnet-az2"
    }
  
}

#  route table for private subnet az2
resource "aws_route_table" "client_private_rt_az2" {
    vpc_id = aws_vpc.client_vpc.id

    route {
        cidr_block = "10.0.0.0/16"
        vpc_peering_connection_id = aws_vpc_peering_connection.api_client_vpc_peering.id
    }

    tags = {
        Name = "client-private-rt-az2"
    }
  
}

#  route table associations for private subnets
resource "aws_route_table_association" "client_rta2_az2" {
    subnet_id = aws_subnet.client_private_sn_az2.id
    route_table_id = aws_route_table.client_private_rt_az2.id
}
resource "aws_route_table_association" "client_rta1_az1" {
    subnet_id = aws_subnet.client_private_sn_az1.id
    route_table_id = aws_route_table.client_private_rt_az1.id
}

###########################################
# VPC peering connection accepter
###########################################
resource "aws_vpc_peering_connection_accepter" "api_client_vpc_peering" {
  vpc_peering_connection_id = aws_vpc_peering_connection.api_client_vpc_peering.id
  auto_accept               = true

    tags = {
    Name = "api-client-vpc-peering",
    Side = "Accepter"
  }
}

