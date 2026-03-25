# Create a VPC
resource "aws_vpc" "webapp-vpc" {
  cidr_block = "10.0.0.0/20"

  tags = var.tags
}

#region Subnets

resource "aws_subnet" "public1-sn" {
  vpc_id     = aws_vpc.webapp-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = eu-west-2a

  tags = var.tags
}

resource "aws_subnet" "public2-sn" {
  vpc_id     = aws_vpc.webapp-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = eu-west-2b

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
  vpc_id     = aws_vpc.webapp-vpc.id
  cidr_block = "10.0.5.0/24"

  tags = {
    Name = "Main"
  }
}

#endregion

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.webapp-vpc.id
}

resource "aws_internet_gateway_attachment" "igw-attach" {
  internet_gateway_id = aws_internet_gateway.igw.id
  vpc_id              = aws_vpc.webapp-vpc.id
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

#region Security Groups

resource "aws_security_group" "allow-https-sg" {
  name        = "allow-https"
  description = "Allow HTTP and HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.webapp-vpc.id

}
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow-https-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.allow-https-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_security_group" "allow-ecs-to-rds-sg" {
  name        = "allow-ecs-to-rds"
  description = "Allow traffic from ecs tasks to rds"
  vpc_id      = aws_vpc.webapp-vpc.id
}
resource "aws_vpc_security_group_ingress_rule" "allow-ecs-to-rds1" {
  security_group_id = aws_security_group.allow-ecs-to-rds-sg.id
  cidr_ipv4 = aws_subnet.private1-sn.cidr_block
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}
resource "aws_vpc_security_group_ingress_rule" "allow-ecs-to-rds2" {
  security_group_id = aws_security_group.allow-ecs-to-rds-sg.id
  cidr_ipv4 = aws_subnet.private2-sn.cidr_block
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_security_group" "ecstask-sg" {
  name        = "security group for ecs task"
  description = "Allow traffic from ecs tasks to rds and alb"
  vpc_id      = aws_vpc.webapp-vpc.id
}
# resource "aws_vpc_security_group_ingress_rule" "allow-from-alb" {
#   security_group_id = aws_security_group.ecstask-sg.id
#   //cidr_ipv4 = alb resource
#   from_port   = 5000
#   ip_protocol = "tcp"
#   to_port     = 5000
# }
# resource "aws_vpc_security_group_egress_rule" "outbount-to-rds" {
#   security_group_id = aws_security_group.ecstask-sg.id
#   //cidr_ipv4         = rds resource
#   from_port   = 5432
#   ip_protocol = "tcp"
#   to_port     = 5432
# }




#endregion

// private_rds SG
//private ec2 task SG

// route table from private subnets to NAT gateway



