resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
             Name = "vpc"
           }

}
#creating  private subnet
resource "aws_subnet" "Subnet1" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = "true" //it makes this a private subnet
    availability_zone = "eu-west-2a"
    tags = {
              Name = "Subnet1"
          }
}
resource "aws_subnet" "Subnet2" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "false" //it makes this a private subnet
    availability_zone = "eu-west-2a"
    tags = {
             Name = "Subnet2"
           }

}
resource "aws_eip" "lb" {
  vpc      = true
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}
resource "aws_nat_gateway" "natg" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.Subnet1.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_default_route_table" "drt" {

 default_route_table_id = aws_vpc.vpc.default_route_table_id

 tags = {
   Name = "def RT"
  }
}
resource "aws_route" "r" {
 # count                  = "${length(local.public_subnets)}"
  route_table_id         = "${aws_default_route_table.drt.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

 # route {
   # cidr_block = "10.0.0.0/16"
  #  gateway_id = "local"
 # }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id =aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Custom route Table"
  }
}
resource "aws_route_table_association" "rta" {
 # count = "${length(local.Subnet1)}"
  subnet_id = aws_subnet.Subnet1.id # first subnet
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table" "rtprivate" {
  vpc_id = aws_vpc.vpc.id

 route {
    cidr_block = "0.0.0.0/0"
    gateway_id =aws_nat_gateway.natg.id
  }

  tags = {
    Name = "custom route table private"
  }
}
resource "aws_route_table_association" "rtb" {
 # count = "${length(local.Subnet1)}"
  subnet_id = aws_subnet.Subnet2.id # 2nd subnet
  route_table_id = aws_route_table.rtprivate.id
}


resource "aws_instance" "web" {
  ami = "ami-0caca849d4c5aa0f1"
  subnet_id = aws_subnet.Subnet1.id
  associate_public_ip_address = "true"
  instance_type = "t3.micro"
  key_name = "terraform-assignment"
  tags = {
    Name = "Webserver"
  }
}

resource "aws_instance" "DB" {
  ami = "ami-0caca849d4c5aa0f1"
  subnet_id = aws_subnet.Subnet2.id
  associate_public_ip_address = "false"
  instance_type = "t3.micro"
  key_name = "terraform-assignment"
  tags = {
    Name = "DB instance"
  }
}
