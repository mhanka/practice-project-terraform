// Create a new VPC with the specified CIDR block
resource "aws_vpc" "project-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "Project"
  }
}

// Create an internet gateway
resource "aws_internet_gateway" "project-gw" {
  vpc_id = aws_vpc.project-vpc.id

  tags = {
    Name = "main"
  }
}

// Create a route table and a route
resource "aws_route_table" "project-route" {
  vpc_id = aws_vpc.project-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project-gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.project-gw.id
  }

  tags = {
    Name = "Project"
  }
}

// Create a subnet
resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.project-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = "project-subnet"
  }
}

// Associate the route table with the subnet
resource "aws_route_table_association" "project-a" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.project-route.id
}

// Create a security group
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.project-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 447
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  tags = {
    Name = "allow_tls"
  }
}

// Create a network interface with an IP in the subnet
resource "aws_network_interface" "web-server-interface" {
  subnet_id       = aws_subnet.subnet-2.id
  private_ips     = var.private_ips
  security_groups = [aws_security_group.allow_web.id]
}

// Create an Elastic IP
resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web-server-interface.id
  associate_with_private_ip = var.private_ip
  depends_on = [ aws_instance.web-server-instance ]
}

// Create a new EC2 instance for starting our web server
resource "aws_instance" "web-server-instance" {
  ami               = var.ami
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  key_name          = var.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-interface.id
  }
  user_data = <<-EOF
              #!/bin/bas
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo your web server created with AWS and Terraform> /var/www/html/index.html'
              EOF

  tags = {
    Name = "web-server" 
  }
}