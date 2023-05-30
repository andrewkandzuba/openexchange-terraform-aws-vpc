provider "aws" {
  region = var.region_name
  default_tags {
    tags = {
      Environment = "Dev"
      Name        = "Provider Tag",
      Purpose     = "Test"
      Stack       = "test"
    }
  }
}