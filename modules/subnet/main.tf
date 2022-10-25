
#private subnet
resource "aws_subnet" "test-vpc-subnet-private" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block_private
    availability_zone = var.avail_zone
    map_public_ip_on_launch = false
    tags = {
      Name: "${var.env_prefix}-subnet-private"
    }
}

#public subnet
resource "aws_subnet" "test-vpc-subnet-public" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block_public
    availability_zone = var.avail_zone
    map_public_ip_on_launch = true
    tags = {
      Name: "${var.env_prefix}-subnet-public"
    }
}

#internet gateway
resource "aws_internet_gateway" "ig-public" {
    vpc_id = var.vpc_id
    tags = {
      Name: "${var.env_prefix}-igw-pub"
    }
}

#EIP for NAT
resource "aws_eip" "nat-eip" {
    vpc = true
    tags = {
      Name: "${var.env_prefix}-nat-eip"
    }
}

#NAT
resource "aws_nat_gateway" "nat-gw" {
    allocation_id = aws_eip.nat-eip.id
    subnet_id     = aws_subnet.test-vpc-subnet-public.id
    
    tags = {
      Name: "${var.env_prefix}-nat-gw"
    }
    depends_on = [aws_internet_gateway.ig-public]
}

#===Route Tables=====>
#public subnet route table

resource "aws_route_table" "route-table-public" {
    vpc_id = var.vpc_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig-public.id
    }
    tags = {
      Name: "${var.env_prefix}-rtb-public"
    }
}
resource "aws_route_table_association" "test-rtb-subnet-public" {
    subnet_id = aws_subnet.test-vpc-subnet-public.id 
    route_table_id = aws_route_table.route-table-public.id
}



#private subnet route table
resource "aws_route_table" "route-table-private" {
    vpc_id = var.vpc_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat-gw.id
    }
    tags = {
      Name: "${var.env_prefix}-rtb-private"
    }
}
resource "aws_route_table_association" "test-rtb-subnet-private" {
    subnet_id = aws_subnet.test-vpc-subnet-private.id
    route_table_id = aws_route_table.route-table-private.id
}