
#==== VPC's Default Security Group =====
resource "aws_security_group" "test-sg" {
    vpc_id = var.vpc_id
    name = "test-sg"

    ingress {
        description = "allow SSH"
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    #outgoing traffic 
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name: "${var.env_prefix}-sg"
    }
}

#FETCHING AWS IMAGES
data "aws_ami" "latest-amazon-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

#key pair creation
resource "aws_key_pair" "ssh-key" {
    key_name = "new-server-key2"
    public_key = "${file(var.public_key_location)}"
}

#EC2 INSTANCE PUBLIC
resource "aws_instance" "test-instance" {
    ami = data.aws_ami.latest-amazon-image.id
    instance_type = var.instance_type

    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.test-sg.id]
    availability_zone = var.avail_zone

    key_name = aws_key_pair.ssh-key.key_name
    associate_public_ip_address = true

    connection {
        type = "ssh"
        host = self.public_ip
        user = "ec2-user"
        private_key = file(var.private_key_location)
    }

    provisioner "file" {
        source = "/home/sha/.ssh/id_rsa"
        destination = "/home/ec2-user/.ssh/id_rsa"
    }

    provisioner "remote-exec" {
        inline = [
          "chmod 400 /home/ec2-user/.ssh/id_rsa",
        ]
    }

    tags = {
        Name: "${var.env_prefix}-public"
    }
}

#ec2 instance private
resource "aws_instance" "test-instance-private" {
    ami = data.aws_ami.latest-amazon-image.id
    instance_type = var.instance_type

    subnet_id = var.subnet_id_private
    vpc_security_group_ids = [aws_security_group.test-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = false
    key_name = aws_key_pair.ssh-key.key_name

    tags = {
        Name: "${var.env_prefix}-private"
    }
}