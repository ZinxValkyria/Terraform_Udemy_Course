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
    Name        = "dev_IG"
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
  subnet_id      = aws_subnet.mySUBNET.id
  route_table_id = aws_route_table.myTABLE.id
}

resource "aws_security_group" "mtc_sg" {
  name        = "dev_sg"
  description = "Dev_security_group"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

}
resource "aws_key_pair" "mtc_auth" {
  key_name   = "mtckey"
  public_key = file("~/.ssh/mtckey.pub")

}

resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = "ami-053b0d53c279acc90"
  key_name               = aws_key_pair.mtc_auth.id
  vpc_security_group_ids = [aws_security_group.mtc_sg.id]
  subnet_id              = aws_subnet.mySUBNET.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }
  tags = {
    Name = "dev_node"
  }
}
