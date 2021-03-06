resource "aws_internet_gateway" "main" {
  vpc_id = "${ aws_vpc.main.id }"

  tags = {
    builtWith         = "terraform"
    KubernetesCluster = "${ var.name }"
    t8s               = "${ var.name }"
    Name              = "t8s-${ var.name }"
  }
}

resource "aws_subnet" "public" {
  count = "${ length( split(",", var.azs) ) }"

  availability_zone = "${ element( split(",", var.azs), var.cidr-offset-subnet + count.index ) }"
  cidr_block        = "${ cidrsubnet(var.cidr, var.cidr-newbits, var.cidr-offset-subnet + count.index) }"
  vpc_id            = "${ aws_vpc.main.id }"

  tags =  {
    "kubernetes.io/role/elb" = "${ var.name }"
    builtWith                = "terraform"
    KubernetesCluster        = "${ var.name }"
    t8s                      = "${ var.name }"
    Name                     = "t8s-${ var.name }-public"
    visibility               = "public"
  }
}

resource "aws_route" "public" {
  route_table_id         = "${ aws_vpc.main.main_route_table_id }"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${ aws_internet_gateway.main.id }"
}

resource "aws_route_table_association" "public" {
  count = "${ length(split(",", var.azs)) }"

  route_table_id = "${ aws_vpc.main.main_route_table_id }"
  subnet_id      = "${ element(aws_subnet.public.*.id, count.index) }"
}
