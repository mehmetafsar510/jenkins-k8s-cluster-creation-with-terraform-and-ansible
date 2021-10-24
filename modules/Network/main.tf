data "aws_availability_zones" "available" {
  exclude_names = ["us-east-1c", "us-east-1b", "us-east-1e", "us-east-1f","us-east-1a" ]
}

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}
resource "aws_vpc" "prod-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"

  tags = {
    Name = "prod-vpc"
  }
}

resource "aws_subnet" "prod-subnet-public" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "prod-subnet-public-${count.index + 1}"
  }
}

resource "aws_subnet" "prod-subnet-private" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = "false" //it makes this a privatesubnet
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "prod-subnet-private-${count.index + 1}"
  }
}

# create an IGW (Internet Gateway)
# It enables your vpc to connect to the internet
resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod-igw"
  }
}

# create a custom route table for public subnets
# public subnets can reach to the internet buy using this
resource "aws_route_table" "prod-public-crt" {
  vpc_id = aws_vpc.prod-vpc.id
  route {
    cidr_block = "0.0.0.0/0"                      //associated subnet can reach everywhere
    gateway_id = aws_internet_gateway.prod-igw.id //CRT uses this IGW to reach internet
  }

  tags = {
    Name = "prod-public-crt"
  }
}

resource "aws_route_table" "prod-private-crt" {
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
    Name = "prod-private-crt"
  }
}

#resource "aws_route" "private_nat_gateway" {
#  route_table_id         = aws_route_table.prod-private-crt.id
#  destination_cidr_block = "0.0.0.0/0"
#  nat_gateway_id         = aws_nat_gateway.nat.id
#}

# route table association for the public subnets
resource "aws_route_table_association" "public" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.prod-subnet-public.*.id[count.index]
  route_table_id = aws_route_table.prod-public-crt.id
}

resource "aws_route_table_association" "private" {
  count          = var.private_sn_count
  subnet_id      = aws_subnet.prod-subnet-private.*.id[count.index]
  route_table_id = aws_route_table.prod-private-crt.id
}

#resource "aws_eip" "nat" {
#  vpc = true
#}
#
#resource "aws_nat_gateway" "nat" {
#  allocation_id = aws_eip.nat.id
#  subnet_id     = element(aws_subnet.prod-subnet-public-1.*.id, 0)
#  depends_on    = [aws_internet_gateway.prod-igw]
#}
