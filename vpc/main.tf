# Internet VPC
resource "aws_vpc" "tf-main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "tf-main"
  }
}

# Subnets
resource "aws_subnet" "tf-main-public-1" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.tf-main.id
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "tf-main-public-1"
    Mode = "public"
  }
}

resource "aws_subnet" "tf-main-public-2" {
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.tf-main.id
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "tf-main-public-2"
    Mode = "public"
  }
}

resource "aws_subnet" "tf-main-public-3" {
  cidr_block              = "10.0.3.0/24"
  vpc_id                  = aws_vpc.tf-main.id
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1c"
  tags = {
    Name = "tf-main-public-3"
    Mode = "public"
  }
}

resource "aws_subnet" "tf-main-public-4" {
  cidr_block              = "10.0.4.0/24"
  vpc_id                  = aws_vpc.tf-main.id
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1d"
  tags = {
    Name = "tf-main-public-4"
    Mode = "public"
  }
}

resource "aws_subnet" "tf-main-public-5" {
  cidr_block              = "10.0.5.0/24"
  vpc_id                  = aws_vpc.tf-main.id
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1e"
  tags = {
    Name = "tf-main-public-5"
    Mode = "public"
  }
}

resource "aws_subnet" "tf-main-public-6" {
  cidr_block              = "10.0.6.0/24"
  vpc_id                  = aws_vpc.tf-main.id
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1f"
  tags = {
    Name = "tf-main-public-6"
    Mode = "public"
  }
}

resource "aws_subnet" "tf-main-private-1" {
  cidr_block              = "10.0.7.0/24"
  vpc_id                  = aws_vpc.tf-main.id
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "tf-main-private-1"
    Mode = "private"
  }
}

resource "aws_subnet" "tf-main-private-2" {
  cidr_block              = "10.0.8.0/24"
  vpc_id                  = aws_vpc.tf-main.id
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "tf-main-private-2"
    Mode = "private"
  }
}

resource "aws_subnet" "tf-main-private-3" {
  cidr_block              = "10.0.9.0/24"
  vpc_id                  = aws_vpc.tf-main.id
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1c"
  tags = {
    Name = "tf-main-private-3"
    Mode = "private"
  }
}

resource "aws_subnet" "tf-main-private-4" {
  cidr_block              = "10.0.10.0/24"
  vpc_id                  = aws_vpc.tf-main.id
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1d"
  tags = {
    Name = "tf-main-private-4"
    Mode = "private"
  }
}

resource "aws_subnet" "tf-main-private-5" {
  cidr_block              = "10.0.11.0/24"
  vpc_id                  = aws_vpc.tf-main.id
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1e"
  tags = {
    Name = "tf-main-private-5"
    Mode = "private"
  }
}

resource "aws_subnet" "tf-main-private-6" {
  cidr_block              = "10.0.12.0/24"
  vpc_id                  = aws_vpc.tf-main.id
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1f"
  tags = {
    Name = "tf-main-private-6"
    Mode = "private"
  }
}

# Internet GW

resource "aws_internet_gateway" "tf-main-gw" {
  vpc_id = aws_vpc.tf-main.id
  tags = {
    Name = "my-gateway"
  }
}

resource "aws_route_table" "tf-main-public" {
  vpc_id = aws_vpc.tf-main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-main-gw.id
  }
  tags = {
    Name = "main-public-1"
  }
}

# route association public

resource "aws_route_table_association" "tf-public-1-a" {
  route_table_id = aws_route_table.tf-main-public.id
  subnet_id      = aws_subnet.tf-main-public-1.id
}

resource "aws_route_table_association" "tf-public-1-b" {
  route_table_id = aws_route_table.tf-main-public.id
  subnet_id      = aws_subnet.tf-main-public-2.id
}

resource "aws_route_table_association" "tf-public-1-c" {
  route_table_id = aws_route_table.tf-main-public.id
  subnet_id      = aws_subnet.tf-main-public-3.id
}

resource "aws_route_table_association" "tf-public-1-d" {
  route_table_id = aws_route_table.tf-main-public.id
  subnet_id      = aws_subnet.tf-main-public-4.id
}

resource "aws_route_table_association" "tf-public-1-e" {
  route_table_id = aws_route_table.tf-main-public.id
  subnet_id      = aws_subnet.tf-main-public-5.id
}

resource "aws_route_table_association" "tf-public-1-f" {
  route_table_id = aws_route_table.tf-main-public.id
  subnet_id      = aws_subnet.tf-main-public-6.id
}

//# nat gw
//resource "aws_eip" "tf-nat" {
//  vpc = true
//}
//
//resource "aws_nat_gateway" "tf-nat-gw" {
//  allocation_id = "${aws_eip.tf-nat.id}"
//  subnet_id = "${aws_subnet.tf-main-public-1.id}"
//  depends_on = ["aws_internet_gateway.tf-main-gw"]
//}
//
//# VPC setup on nat
//resource "aws_route_table" "tf-main-private" {
//  vpc_id = "${aws_vpc.tf-main.id}"
//  route {
//    cidr_block = "0.0.0.0/0"
//    nat_gateway_id = "${aws_nat_gateway.tf-nat-gw.id}"
//  }
//  tags {
//    Name = "main-private-1"
//  }
//}
//
//# route associations private
//resource "aws_route_table_association" "tf-main-private-1-a" {
//  route_table_id = "${aws_route_table.tf-main-private.id}"
//  subnet_id = "${aws_subnet.tf-main-private-1.id}"
//}
//
//resource "aws_route_table_association" "tf-main-private-1-b" {
//  route_table_id = "${aws_route_table.tf-main-private.id}"
//  subnet_id = "${aws_subnet.tf-main-private-2.id}"
//}
//
//resource "aws_route_table_association" "tf-main-private-1-c" {
//  route_table_id = "${aws_route_table.tf-main-private.id}"
//  subnet_id = "${aws_subnet.tf-main-private-3.id}"
//}
//
//resource "aws_route_table_association" "tf-main-private-1-d" {
//  route_table_id = "${aws_route_table.tf-main-private.id}"
//  subnet_id = "${aws_subnet.tf-main-private-4.id}"
//}
//
//resource "aws_route_table_association" "tf-main-private-1-e" {
//  route_table_id = "${aws_route_table.tf-main-private.id}"
//  subnet_id = "${aws_subnet.tf-main-private-5.id}"
//}
//
//resource "aws_route_table_association" "tf-main-private-1-f" {
//  route_table_id = "${aws_route_table.tf-main-private.id}"
//  subnet_id = "${aws_subnet.tf-main-private-6.id}"
//}
