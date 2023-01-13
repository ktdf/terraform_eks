resource "aws_vpc" "this" {
  cidr_block = var.cidr
  tags = {
    "Name" = var.vpc_name
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = try(element(var.availability_zones, count.index), null)
  tags = merge(
    var.private_subnet_tags,
    {
      "Name" = format("Private-%s", count.index + 1)
    }
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.public_subnets, count.index)
  availability_zone = try(element(var.availability_zones, count.index), null)
  tags = merge(
    var.public_subnet_tags,
    {
      "Name" = format("Public-%s", count.index + 1)
    }
  )
}

resource "aws_internet_gateway" "this" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "public" {
  count = length(var.public_subnets)

  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  route_table_id = element(aws_route_table.public, count.index).id
  subnet_id      = element(aws_subnet.public, count.index).id
}

resource "aws_eip" "this" {
  count      = min(length(var.public_subnets), length(var.private_subnets))
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = min(length(var.public_subnets), length(var.private_subnets))

  subnet_id     = element(aws_subnet.public, count.index).id
  allocation_id = element(aws_eip.this, count.index).id

  depends_on = [aws_internet_gateway.this[0]]
}

resource "aws_route_table" "private" {
  count = length(var.public_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.this, count.index).id
  }

}

resource "aws_route_table_association" "private" {
  count = length(var.public_subnets) > 0 ? length(var.private_subnets) : 0

  route_table_id = element(aws_route_table.private, count.index).id
  subnet_id      = element(aws_subnet.private, count.index).id
}