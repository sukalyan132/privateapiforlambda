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



###########################################
# DNS resolution for private api endpoint
###########################################

resource "aws_route53_resolver_endpoint" "outbound_resolver_ep" {

  name      = "private-api-outbound-resolver-endpoint"
  direction = "OUTBOUND"
  security_group_ids = [aws_security_group.outbound_resolver_ep_sg.id]

  ip_address {
    subnet_id = aws_subnet.client_private_sn_az1.id
    ip        = "172.128.1.10"
  }

  ip_address {
    subnet_id = aws_subnet.client_private_sn_az2.id
    ip        = "172.128.2.10"
  }

  tags = {
    Name = "private-api-resolver-endpoint"
  }
}


#  route53 resolver rule our outbound resolver
resource "aws_route53_resolver_rule" "private_api_resolver_rule" {
  name        = "private-api-resolver-rule"
  domain_name = var.private_api_domain_name
  rule_type   = "FORWARD"
  
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_resolver_ep.id
  target_ip     {
    ip = "10.0.0.2"
  }
  target_ip     {
    ip = "10.0.1.10"
  }
  target_ip     {
    ip = "10.0.2.10"
  }

  depends_on = [ aws_route53_resolver_endpoint.outbound_resolver_ep ]
  tags = {
    Name = "private-api-resolver-rule"
  }
}

# route53 resolver rule association with client_vpc
resource "aws_route53_resolver_rule_association" "private_api_resolver_rule_assoc" {
  resolver_rule_id = aws_route53_resolver_rule.private_api_resolver_rule.id
  vpc_id = aws_vpc.client_vpc.id
}



###########################################
# SSM endpoints to access EC2 instances in private subnet
###########################################
resource "aws_vpc_endpoint" "ssm_ep" {
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_id              = aws_vpc.client_vpc.id
  subnet_ids          = [aws_subnet.client_private_sn_az1.id]
  security_group_ids  = [aws_security_group.ssm_ep_sg.id]
  tags = {
    Name = "ssm-endpoint"
  }
}
resource "aws_vpc_endpoint" "ssm_messages_ep" {
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_id              = aws_vpc.client_vpc.id
  subnet_ids          = [aws_subnet.client_private_sn_az1.id]
  security_group_ids  = [aws_security_group.ssm_ep_sg.id]
  tags = {
    Name = "ssm-messages-endpoint"
  }
}
