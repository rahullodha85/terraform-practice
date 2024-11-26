data "aws_vpc" "default" {
  filter {
    name   = "tag:Name"
    values = ["tf-main"]
  }
}

data "aws_route_table" "main_public" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "tag:Name"
    values = ["main-public-1"]
  }
}

data "aws_subnet" "subnet" {
  count = var.COUNT
  availability_zone = element(
    data.aws_availability_zones.availability-zones.names,
    count.index,
  )
  tags = {
    "Mode" = "public"
  }
}

data "aws_subnet" "subnet_private" {
  count = var.COUNT
  availability_zone = element(
    data.aws_availability_zones.availability-zones.names,
    count.index,
  )
  tags = {
    "Mode" = "private"
  }
}

data "aws_availability_zones" "availability-zones" {
  state = "available"
}

