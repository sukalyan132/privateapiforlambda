###############################
# execution role for lambda
###############################
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

##################################
# Using managed IAM policies for VPC EC2 networking, Cloudwatch & DynamoDB
##################################

# see https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AWSLambdaVPCAccessExecutionRole.html
resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

##################################
# Lambda Infrastructure
##################################
data "archive_file" "create_handler_zip" {
  type        = "zip"
  source_dir = "${path.module}/src/handlers/"
  output_path = "${path.module}/src/archives/create.zip"

}

resource "aws_lambda_function" "createClaim" {
  filename      = data.archive_file.create_handler_zip.output_path
  function_name = var.create_function_name
  handler       = "create.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 30
  runtime       = "nodejs20.x"
  source_code_hash = data.archive_file.create_handler_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.private_sn_az1.id, aws_subnet.private_sn_az2.id]
    security_group_ids = [aws_security_group.private_lambda_sg.id]
  }
  logging_config {
    log_format = "Text"
  }
}

#  log groups for CRUD functions
resource "aws_cloudwatch_log_group" "createClaim" {
  name              = "/aws/lambda/${aws_lambda_function.createClaim.function_name}"
  retention_in_days = 14
}

# API Gateway Invoke Lambda permissions

resource "aws_lambda_permission" "apigw_create_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.createClaim.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*"
}






