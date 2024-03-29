resource "aws_vpc" "this" {
    cidr_block = var.cidr_block
    enable_dns_support = true
    enable_dns_hostnames = true
}

data "aws_availability_zones" "available" {
}

resource "aws_subnet" "private_subnet" {
    count = var.count_private_subnet
    cidr_block = cidrsubnet(var.cidr_block, 8, count.index + 128)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    vpc_id = aws_vpc.this.id
    map_public_ip_on_launch = false
    tags = {
        Name = "${var.environment}:Subnet:${var.project_name}:PrivateSubnet-${count.index}"
        "kubernetes.io/role/internal-elb": 1
        "kubernetes.io/cluster/${var.eks_cluster_name}": "shared"
    }

}

resource "aws_subnet" "public_subnet" {
    count = var.count_public_subnet
    cidr_block = cidrsubnet(var.cidr_block, 8, count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    vpc_id = aws_vpc.this.id
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.environment}:Subnet:${var.project_name}:PublicSubnet-${count.index}"
        "kubernetes.io/role/elb": 1
        "kubernetes.io/cluster/${var.eks_cluster_name}": "shared"
    }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.environment}:InternetGateway:${var.project_name}"
  }
}

resource "aws_eip" "vpc_nat_gateway_eip" {
  domain           = "vpc"
}

resource "aws_nat_gateway" "ineedinternet" {
  allocation_id = aws_eip.vpc_nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${var.environment}:Natgatway:${var.project_name}"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.environment}:RouteTable:${var.project_name}:Public"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ineedinternet.id
  }

  tags = {
    Name = "${var.environment}:RouteTable:${var.project_name}:Private"
  }
}

resource "aws_route_table_association" "public_route_association" {
  count          = var.count_public_subnet
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_association" {
  count          = var.count_private_subnet
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
