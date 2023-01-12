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
