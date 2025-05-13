terraform {
  backend "s3" {
    bucket = "project-terraform-jenkins-eks"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"

  }
}