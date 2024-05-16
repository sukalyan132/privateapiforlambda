output "claim_url" {
  description = "The API Gateway invocation url pointing to the stage"
  value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.dev.stage_name}/${aws_api_gateway_resource.claim.path_part}"
}

output "execute_api_endpoint" {
  value = aws_vpc_endpoint.execute_api_ep.id
}
output "execute_api_endpoint_dns_name" {
    value = aws_vpc_endpoint.execute_api_ep.dns_entry[0].dns_name
}
output "execute_api_arn" {
    value = aws_api_gateway_rest_api.this.arn
}
