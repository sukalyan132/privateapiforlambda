
# security group for private API VPC Interface endpoint
resource "aws_security_group" "execute_api_ep_sg" {
  name        = "execute-api-endpoint-sg"
  description = "Security group for API Gateway VPC endpoint"
  vpc_id      = aws_vpc.api_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.private_sn_az1.cidr_block}", "${aws_subnet.private_sn_az2.cidr_block}", "${aws_subnet.client_private_sn_az1.cidr_block}", "${aws_subnet.client_private_sn_az2.cidr_block}"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "ssm2_ep_sg" {
  name        = "ssm2-endpoint-sg"
  description = "Security group for SSM endpoints for api-vpc instances"
  vpc_id      = aws_vpc.api_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.private_sn_az1.cidr_block}", "${aws_subnet.private_sn_az2.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "ssm_ep_sg" {
  name        = "ssm-endpoint-sg"
  description = "Security group for SSM endpoints for client-vpc clients"
  vpc_id      = aws_vpc.client_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.client_private_sn_az1.cidr_block}", "${aws_subnet.client_private_sn_az2.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "private_lambda_sg" {
  name        = "private-lambda-sg"
  description = "Security group for private lambdas"
  vpc_id      = aws_vpc.api_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.private_sn_az1.cidr_block}", "${aws_subnet.private_sn_az2.cidr_block}"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}
