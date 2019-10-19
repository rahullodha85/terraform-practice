data "aws_vpc" "default" {
  filter {
    name   = "tag:Name"
    values = ["tf-main"]
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

data "aws_availability_zones" "availability-zones" {
  state = "available"
}

