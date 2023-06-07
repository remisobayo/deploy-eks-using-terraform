terraform {
  # add terraform backend location
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "tfbucket-remotestate"
    key            = "global/mavenapp/terraform.tfstate"
    region         = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
