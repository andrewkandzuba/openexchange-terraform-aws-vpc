provider "aws" {
  region = var.region_names[0]
  default_tags {
    tags = {
      Environment = "Dev"
      Name        = "Provider Tag",
      Purpose     = "Test"
      Stack       = "test"
    }
  }
}