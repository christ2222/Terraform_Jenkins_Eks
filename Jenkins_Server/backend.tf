# backend.tf
terraform {
  backend "s3" {
    bucket = "project-terraform-jenkins-eks"
    key    = "prod/eks.tfstate"
    region = "us-east-1"
  }
}