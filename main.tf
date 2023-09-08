resource "aws_vpc" "myVPC" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}
resource "aws_subnet" "mySUBNET" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "dev-public"
  }

}

resource "aws_internet_gateway" "myGATEWAY" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "dev_IG"
    Description = "My Internet Gateway"
  }

}
resource "aws_route_table" "myTABLE" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "dev-public-rt"
  }
}
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.myTABLE.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myGATEWAY.id


}
resource "aws_route_table_association" "myROUTE_TABLE" {
    subnet_id = aws_subnet.mySUBNET.id
    route_table_id = aws_route_table.myTABLE.id
}

  