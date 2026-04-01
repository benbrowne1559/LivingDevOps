# Create a VPC
resource "aws_vpc" "webapp-vpc" {
  cidr_block = "10.0.0.0/20"

  tags = var.tags
}

#region Subnets

resource "aws_subnet" "public1-sn" {
  vpc_id            = aws_vpc.webapp-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = var.tags
}

resource "aws_subnet" "public2-sn" {
  vpc_id            = aws_vpc.webapp-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = var.tags
}

resource "aws_subnet" "private1-sn" {
  vpc_id     = aws_vpc.webapp-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = var.tags
}
resource "aws_subnet" "private2-sn" {
  vpc_id     = aws_vpc.webapp-vpc.id
  cidr_block = "10.0.3.0/24"

  tags = var.tags
}
resource "aws_subnet" "private-rds-sn" {
  count = 2
  vpc_id     = aws_vpc.webapp-vpc.id
  cidr_block = var.private-rds-subnet[count.index].cidr_block
  availability_zone = var.private-rds-subnet[count.index].avail_zone

  tags = {
    Name = "Private RDS Subnet-${count.index}"
  }
}

#endregion

#region Nat/IG

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.webapp-vpc.id
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1-sn.id

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.igw]
}
resource "aws_eip" "eip" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.igw]
}

#endregion

#region Security Groups

resource "aws_security_group" "allow-inbound-elb-sg" {
  name        = "allow-inbound-elb-sg"
  description = "Allow HTTP and HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.webapp-vpc.id

}
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow-inbound-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.allow-inbound-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_egress_rule" "allow-all-outbound1" {
  security_group_id = aws_security_group.allow-inbound-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_security_group" "rds-sg" {
  name        = "allow-ecs-to-rds"
  description = "Allow traffic from ecs tasks to rds"
  vpc_id      = aws_vpc.webapp-vpc.id
}
resource "aws_vpc_security_group_ingress_rule" "allow-ecs-to-rds1" {
  security_group_id = aws_security_group.rds-sg.id
  cidr_ipv4         = aws_subnet.private1-sn.cidr_block
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}
resource "aws_vpc_security_group_ingress_rule" "allow-ecs-to-rds2" {
  security_group_id = aws_security_group.rds-sg.id
  cidr_ipv4         = aws_subnet.private2-sn.cidr_block
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_security_group" "ecstask-sg" {
  name        = "security group for ecs task"
  description = "Allow traffic from ecs tasks to rds and alb"
  vpc_id      = aws_vpc.webapp-vpc.id
}
resource "aws_vpc_security_group_ingress_rule" "allow-from-alb2" {
  security_group_id = aws_security_group.ecstask-sg.id
  cidr_ipv4         = aws_subnet.public2-sn.cidr_block
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}
resource "aws_vpc_security_group_ingress_rule" "allow-from-alb" {
  security_group_id = aws_security_group.ecstask-sg.id
  cidr_ipv4         = aws_subnet.public1-sn.cidr_block
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}

resource "aws_vpc_security_group_egress_rule" "allow-all-outbound" {
  security_group_id = aws_security_group.ecstask-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#endregion

// route table from private subnets to NAT gateway

#region Route Tables

resource "aws_route_table" "nat-rt" {
  vpc_id = aws_vpc.webapp-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "private to nat route table"
  }
}
resource "aws_route_table_association" "nat-rta" {
  subnet_id      = aws_subnet.private1-sn.id
  route_table_id = aws_route_table.nat-rt.id
}
resource "aws_route_table_association" "nat2-rta" {
  subnet_id      = aws_subnet.private2-sn.id
  route_table_id = aws_route_table.nat-rt.id
}


resource "aws_route_table" "ig-rt" {
  vpc_id = aws_vpc.webapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public to ig route table"
  }
}
resource "aws_route_table_association" "ig-rta" {
  subnet_id      = aws_subnet.public1-sn.id
  route_table_id = aws_route_table.ig-rt.id
}
resource "aws_route_table_association" "ig2-rta" {
  subnet_id      = aws_subnet.public2-sn.id
  route_table_id = aws_route_table.ig-rt.id
}
#endregion
