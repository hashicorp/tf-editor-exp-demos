resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/22"
  tags = {
    "Name" = "Demo"
  }
}

data "aws_availability_zones" "all" {}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_subnet" "public" {
  // count             = 3 // 👈
  // availability_zone = data.aws_availability_zones.all.names[count.index] // 👈
  vpc_id     = aws_vpc.default.id
  cidr_block = "10.0.0.0/24"
  // cidr_block = cidrsubnet("10.0.0.0/22", 2, count.index) // 👈
}

resource "aws_route_table" "name" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public[*])
  route_table_id = aws_route_table.name.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_route" "name" {
  route_table_id         = aws_route_table.name.id
  gateway_id             = aws_internet_gateway.default.id
  destination_cidr_block = "0.0.0.0/0"
}
