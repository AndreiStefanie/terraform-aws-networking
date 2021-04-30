data "aws_availability_zones" "azs" {}

resource "random_integer" "this" {
  min = 1
  max = 99
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tf-vpc-${random_integer.this.id}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "public" {
  count = var.public_sn_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.azs.names, count.index)

  tags = {
    Name = "tf-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = var.private_sn_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)

  tags = {
    Name = "tf-private-${count.index + 1}"
  }
}

resource "aws_db_subnet_group" "rds" {
  count = var.db_subnet_group == "true" ? 1 : 0

  name       = "tf-rds-sng"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "tf-rd-sng"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "tf-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "tf-public-rt"
  }
}

resource "aws_route" "default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = local.any_ip
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_default_route_table" "private" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  tags = {
    Name = "tf-private-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = var.public_sn_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "this" {
  for_each = local.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.this.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = each.value.from_port
      to_port     = each.value.to_port
      protocol    = each.value.protocol
      cidr_blocks = each.value.cidr_blocks
    }
  }

  egress {
    cidr_blocks = [local.any_ip]
    description = "Allow all traffic"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}
