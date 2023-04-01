provider "aws" {
  region     = "us-west-2"
  access_key = "AKIAR4OV6SRI727HFW6O"
  secret_key = "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"


}

resource "aws_instance" "ec2instance" {
  ami                    = "ami-0b029b1931b347543"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.tf-key-pair.key_name
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  user_data              = <<EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install httpd -y
  sudo systemctl start httpd
  sudo systemctl enable httpd
  EOF
  tags = {
    Name = "myvpctask"
  }
}

resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair"
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-0f577c4edcc53a7cf"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
