// Create VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({
    Name = "${var.project_name}-vpc"
  },var.common_tags)
}

// Create Public Subnets
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge({
    Name = "${var.project_name}-public-${count.index + 1}"
  },var.common_tags)
}


// Create Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

   tags = merge({
    Name = "${var.project_name}-igw"
  },var.common_tags)
}

// Create Public Route Table with default route via Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

   tags = merge({
    Name = "${var.project_name}-public-rtb"
  },var.common_tags)
}

// Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_subnet_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

// Create Private Subnets
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = false

   tags = merge({
    Name = "${var.project_name}-private-${count.index + 1}"
  },var.common_tags)
}

//Elastic IP for NAT
resource "aws_eip" "nat_eip" {
 // count = length(var.private_subnet_cidrs)
  domain = "vpc"

  tags = merge({
    Name = "${var.project_name}-nat-eip"//Name = "${var.project_name}-nat-eip-${count.index + 1}"
  },var.common_tags)
}

// Create NAT Gateways
resource "aws_nat_gateway" "this" {
 // count = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat_eip.id // allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id = aws_subnet.public_subnet[0].id  //subnet_id = aws_subnet.public_subnet[count.index].id

  tags = merge({
    Name = "${var.project_name}-nat-gtw" //Name = "${var.project_name}-nat-gtw-${count.index + 1}"
  },var.common_tags)
  
  depends_on = [ aws_internet_gateway.this ]
}

// Create Private Route Tables for each Private Subnet
resource "aws_route_table" "private" {
  //  count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this.id // gateway_id = aws_nat_gateway.this[count.index].id
  }

   tags = merge({
    Name = "${var.project_name}-private-rtb" //Name = "${var.project_name}-private-rtb-${count.index + 1}"
  },var.common_tags)
}

// Associate Private Subnets with their Private Route Tables
resource "aws_route_table_association" "private_subnet_assoc" {
  count = length(var.private_subnet_cidrs)
  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id //route_table_id = aws_route_table.private[count.index].id
}
