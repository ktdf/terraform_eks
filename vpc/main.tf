resource "aws_vpc" "this" {
  cidr_block = var.cidr
  tags = {
    "Name" = var.vpc_name
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)
  vpc_id = aws_vpc.this.id
}