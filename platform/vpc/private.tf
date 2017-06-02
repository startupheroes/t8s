resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  depends_on = [
    "aws_eip.nat",
    "aws_internet_gateway.main",
  ]

  allocation_id = "${ aws_eip.nat.id }"
  subnet_id     = "${ aws_subnet.public.0.id }"
}

resource "aws_subnet" "private" {
  count = "${ length( split(",", var.azs) ) }"

  availability_zone = "${ element( split(",", var.azs), var.cidr-offset-subnet + count.index ) }"
  cidr_block        = "${ cidrsubnet(var.cidr, var.cidr-newbits, var.cidr-offset-subnet + count.index + var.cidr-step-private-subnet) }"
  vpc_id            = "${ aws_vpc.main.id }"

  tags {
    "kubernetes.io/role/internal-elb" = "${ var.name }"
    builtWith                         = "terraform"
    KubernetesCluster                 = "${ var.name }"
    t8s                               = "${ var.name }"
    Name                              = "t8s-${ var.name }-private"
    visibility                        = "private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${ aws_vpc.main.id }"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${ aws_nat_gateway.nat.id }"
  }

  tags {
    builtWith         = "terraform"
    KubernetesCluster = "${ var.name }"
    t8s               = "${ var.name }"
    Name              = "t8s-${ var.name }"
    visibility        = "private"
  }
}

resource "aws_route_table_association" "private" {
  count = "${ length(split(",", var.azs)) }"

  route_table_id = "${ aws_route_table.private.id }"
  subnet_id      = "${ element(aws_subnet.private.*.id, count.index) }"
}
