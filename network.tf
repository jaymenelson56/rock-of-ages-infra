# Use the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get all default subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create a security group for ec2
resource "aws_security_group" "ec2_sg" {
  name        = "rock-of-ages-ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
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

# Create a security group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rock-of-ages-db-sg"
  description = "Allow PostgreSQL connections for Rock of Ages course"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # open for workshop/demo purposes
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rock-of-ages-db-sg"
  }
}

# Create an RDS DB Subnet Group using the default subnets
resource "aws_db_subnet_group" "rock_of_ages" {
  name       = "rock-of-ages-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
  tags = {
    Name = "rock-of-ages-db-subnet-group"
  }
}