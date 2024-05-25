# Using Terraform to build a Private REST API with Amazon API Gateway
This project demonstrates how to use Terraform to build a private REST API with Amazon API Gateway that can only be accessed within a VPC

## Prerequisites
Before you begin, ensure you have the following:

- AWS account
- Terraform installed locally
- AWS CLI installed and configured with appropriate access credentials

## Architecture
![Diagram](private-rest-api-part2-white.webp)

---

## Project Structure
```bash
|- src/
	|- archives/
  |- events/
	|- handlers/
		|- create.mjs
|- locals.tf
|- provider.tf
|- terraform.tfvars.tf
|- variables.tf
|- api-vpc.tf
|- lambda.tf
|- security-groups.tf
|- apigw.tf
|- client-vpc.tf
```
---
## Getting Started

1. Clone this repository:

   ```bash
   git clone https://github.com/sukalyan132/privateapiforlambda.git
   ```
2. Navigate to the project directory:
   ```bash
   cd tf-private-apigw
   ```
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Review and modify `variables.tf` to customize your API configurations.
5. Create a `terraform.tfvars` file in the root directory and pass in values for `region`, `account_id`, `tag_environment` and `tag_project`
   ```bash
    region               = "eu-central-1"
    account_id           = <<your account id>>
    tag_environment      = "dev"
    tag_project          = "tf-private-apigw"
   ```
6. Apply the Terraform configure:
   ```bash
   terraform apply
   ```
7. After the apply is complete, Terraform will output the private API Gateway URL which can be used to access the private Serverless REST API endpoints.

---

## Clean up
Remove all resources created by Terraform.
   ```
   terraform destroy
   ```

