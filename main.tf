terraform {
    required_version = ">= 0.12"
    backend "s3" {
        bucket = "test-app-sha"
        key = "test/state.tfstate"
        region = "us-west-1"
    }
}

provider "aws" {
    region = "us-west-1"
}

#creating the vpc
resource "aws_vpc" "test-vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    enable_dns_support   = true
    tags = {
       Name: "${var.env_prefix}-vpc"
    }
}

module "test-subnet" {
    source = "./modules/subnet"
    vpc_id = aws_vpc.test-vpc.id
    subnet_cidr_block_private = var.subnet_cidr_block_private
    subnet_cidr_block_public = var.subnet_cidr_block_public
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
}

module "test-server" {
    source = "./modules/websever"
    vpc_id = aws_vpc.test-vpc.id
    my_ip = var.my_ip
    env_prefix = var.env_prefix
    public_key_location = var.public_key_location
    private_key_location = var.private_key_location
    instance_type = var.instance_type
    avail_zone = var.avail_zone
    subnet_id = module.test-subnet.subnet.id
    subnet_id_private = module.test-subnet.subnet_private.id

}