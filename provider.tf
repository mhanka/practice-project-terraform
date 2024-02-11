//Configure the AWS Provider
provider "aws" {
  //Set the AWS region
  region = var.aws_region
  //Specify the shared credentials file
  shared_credentials_files = [ "~/.aws/credentials" ]
}