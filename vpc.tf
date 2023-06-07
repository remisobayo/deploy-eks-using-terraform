# VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "app-vpc" #,
    #"kubernetes.io/cluster/${var.project}-cluster" = "shared"
  }
}

# Private Subnets
resource "aws_subnet" "private-us-east-2a" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.private_subnet1_cidr
  availability_zone = "us-east-2a"

  tags = {
    "Name"                            = "private-us-east-2a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
  }
}

resource "aws_subnet" "private-us-east-2b" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.private_subnet2_cidr
  availability_zone = "us-east-2b"

  tags = {
    "Name"                            = "private-us-east-2b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
  }
}

# Public Subnets
resource "aws_subnet" "public-us-east-2a" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.public_subnet1_cidr
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "public-us-east-2a"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
  }
}

resource "aws_subnet" "public-us-east-2b" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.public_subnet2_cidr
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "public-us-east-2b"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    "Name" = "igw"
  }
  depends_on = [aws_vpc.app_vpc]
}

# NAT Elastic IP
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "${var.project}-ngw-ip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-us-east-2a.id

  tags = {
    Name = "${var.project}-ngw"
  }

  depends_on = [aws_internet_gateway.igw]
}


# Route Table(s)
# Route the private subnet traffic through the NGW
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.app_vpc.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.nat.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "${var.project}-private-rt"
  }
}

# Route the public subnet traffic through the IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app_vpc.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.igw.id
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "${var.project}-public-rt"
  }
}

# Route table and subnet associations
resource "aws_route_table_association" "private-us-east-2a" {
  subnet_id      = aws_subnet.private-us-east-2a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-us-east-2b" {
  subnet_id      = aws_subnet.private-us-east-2b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-us-east-2a" {
  subnet_id      = aws_subnet.public-us-east-2a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-us-east-2b" {
  subnet_id      = aws_subnet.public-us-east-2b.id
  route_table_id = aws_route_table.public.id
}


# # Add route to route table
# resource "aws_route" "main" {
#   route_table_id         = aws_vpc.this.default_route_table_id
#   nat_gateway_id         = aws_nat_gateway.main.id
#   destination_cidr_block = "0.0.0.0/0"
# }

