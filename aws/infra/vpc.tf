resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "main"{
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  count = 3
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = count.index == 0 ? "ap-northeast-2a" : count.index == 1 ? "ap-northeast-2b" : "ap-northeast-2c"

  tags = {
    Name = "${var.environment}-private-subnet-${count.index == 0 ? "2a" : count.index == 1 ? "2b" : "2c"}"
  }
}

resource "aws_eip" "bastion" {
  domain = "vpc"
  instance = aws_instance.bastion.id

  depends_on = [aws_instance.bastion, aws_internet_gateway.main]

  tags = {
    Name = "${var.environment}-bastion-eip"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.environment}-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  subnet_id = aws_subnet.public.id
  allocation_id = aws_eip.nat.id

  tags = {
    Name = "${var.environment}-nat-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-private-rt"
  }
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public.id
}

resource "aws_route_table_association" "private" {
  count = 3
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private[count.index].id
}