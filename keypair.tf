// Sends your public key to the instance
resource "aws_key_pair" "default-region-key-pair" {
  key_name   = "default-region-key-pair"
  public_key = file(var.public-key-path)
}