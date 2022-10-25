output "aws-ami" {
  value = data.aws_ami.latest-amazon-image.id
}