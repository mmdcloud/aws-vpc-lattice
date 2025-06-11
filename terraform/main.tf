# Create two demo VPCs
resource "aws_vpc" "vpc1" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Lattice-Demo-VPC1"
  }
}

resource "aws_vpc" "vpc2" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Lattice-Demo-VPC2"
  }
}

# Create subnets in each VPC
resource "aws_subnet" "vpc1_private" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "VPC1-Private"
  }
}

resource "aws_subnet" "vpc2_private" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "VPC2-Private"
  }
}

# Create security groups
resource "aws_security_group" "lattice_sg" {
  name        = "lattice-service-sg"
  description = "Allow traffic for VPC Lattice"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create VPC Lattice Service Network
resource "aws_vpclattice_service_network" "demo_network" {
  name      = "demo-lattice-network"
  auth_type = "AWS_IAM"
  tags = {
    Environment = "Demo"
  }
}

# Associate VPCs to the service network
resource "aws_vpclattice_service_network_vpc_association" "vpc1_assoc" {
  service_network_identifier = aws_vpclattice_service_network.demo_network.id
  vpc_identifier             = aws_vpc.vpc1.id
  security_group_ids         = [aws_security_group.lattice_sg.id]
}

resource "aws_vpclattice_service_network_vpc_association" "vpc2_assoc" {
  service_network_identifier = aws_vpclattice_service_network.demo_network.id
  vpc_identifier             = aws_vpc.vpc2.id
  security_group_ids         = [aws_security_group.lattice_sg.id]
}

# Create target groups for services
resource "aws_vpclattice_target_group" "service1_tg" {
  name = "service1-target-group"
  type = "INSTANCE"

  config {
    port           = 8080
    protocol       = "HTTP"
    vpc_identifier = aws_vpc.vpc1.id
  }
}

resource "aws_vpclattice_target_group" "service2_tg" {
  name = "service2-target-group"
  type = "INSTANCE"

  config {
    port           = 8080
    protocol       = "HTTP"
    vpc_identifier = aws_vpc.vpc2.id
  }
}

# Register demo EC2 instances as targets
resource "aws_instance" "service1" {
  ami                    = "ami-0c55b159cbfafe1f0" # Amazon Linux 2
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.vpc1_private.id
  vpc_security_group_ids = [aws_security_group.lattice_sg.id]
  user_data              = <<-EOF
              #!/bin/bash
              yum install -y docker
              systemctl start docker
              docker run -d -p 8080:80 nginx
              EOF
  tags = {
    Name = "Service1"
  }
}

resource "aws_instance" "service2" {
  ami                    = "ami-0c55b159cbfafe1f0" # Amazon Linux 2
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.vpc2_private.id
  vpc_security_group_ids = [aws_security_group.lattice_sg.id]
  user_data              = <<-EOF
              #!/bin/bash
              yum install -y docker
              systemctl start docker
              docker run -d -p 8080:80 httpd
              EOF
  tags = {
    Name = "Service2"
  }
}

resource "aws_vpclattice_target_group_attachment" "service1_attach" {
  target_group_identifier = aws_vpclattice_target_group.service1_tg.id
  target {
    id   = aws_instance.service1.id
    port = 8080
  }
}

resource "aws_vpclattice_target_group_attachment" "service2_attach" {
  target_group_identifier = aws_vpclattice_target_group.service2_tg.id
  target {
    id   = aws_instance.service2.id
    port = 8080
  }
}

# Create Lattice Services
resource "aws_vpclattice_service" "service1" {
  name            = "service1"
  auth_type       = "AWS_IAM"
  certificate_arn = null # For demo purposes
}

resource "aws_vpclattice_listener" "service1_listener" {
  service_identifier = aws_vpclattice_service.service1.id
  name               = "http-listener"
  port               = 80
  protocol           = "HTTP"

  default_action {
    forward {
      target_groups {
        target_group_identifier = aws_vpclattice_target_group.service1_tg.id
        weight                  = 100
      }
    }
  }
}
resource "aws_vpclattice_service" "service2" {
  name            = "service2"
  auth_type       = "AWS_IAM"
  certificate_arn = null # For demo purposes
}

resource "aws_vpclattice_listener" "service2_listener" {
  service_identifier = aws_vpclattice_service.service2.id
  name               = "http-listener"
  port               = 80
  protocol           = "HTTP"

  default_action {
    forward {
      target_groups {
        target_group_identifier = aws_vpclattice_target_group.service2_tg.id
        weight                  = 100
      }
    }
  }
}

# Associate services to the service network
resource "aws_vpclattice_service_network_service_association" "service1_assoc" {
  service_identifier         = aws_vpclattice_service.service1.id
  service_network_identifier = aws_vpclattice_service_network.demo_network.id
}

resource "aws_vpclattice_service_network_service_association" "service2_assoc" {
  service_identifier         = aws_vpclattice_service.service2.id
  service_network_identifier = aws_vpclattice_service_network.demo_network.id
}

# Create a test client instance
resource "aws_instance" "client" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.vpc1_private.id
  vpc_security_group_ids = [aws_security_group.lattice_sg.id]
  tags = {
    Name = "TestClient"
  }
}
