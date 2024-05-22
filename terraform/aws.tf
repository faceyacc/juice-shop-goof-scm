# Terraform AWS Configuration with Vulnerabilities

provider "aws" {
  region = "us-west-2"
}

# Creating an S3 bucket with public read access
resource "aws_s3_bucket" "vulnerable_bucket" {
  bucket = "vulnerable-bucket"
  acl    = "public-read"  # Publicly readable

  tags = {
    Name = "Vulnerable S3 Bucket"
  }
}

# Creating an IAM user with full access policies
resource "aws_iam_user" "vulnerable_user" {
  name = "vulnerable-user"
}

resource "aws_iam_user_policy" "vulnerable_policy" {
  name   = "vulnerable-policy"
  user   = aws_iam_user.vulnerable_user.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

# Creating an EC2 instance with a security group allowing all traffic
resource "aws_instance" "vulnerable_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "Vulnerable EC2 Instance"
  }

  vpc_security_group_ids = [aws_security_group.vulnerable_sg.id]
}

resource "aws_security_group" "vulnerable_sg" {
  name        = "vulnerable-sg"
  description = "Security group with open ingress and egress"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
