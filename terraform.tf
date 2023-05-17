terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
   
    }
  }
}
resource "aws_security_group" "allow_ssh_http_https" {
  name        = "allow-ssh-http-https2" #or you can create a security groip in AWS and mention it here
  description = "Allow inbound/outbound SSH, HTTP, and HTTPS traffic"
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
  ingress {
    from_port   = 443
    to_port     = 443
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
provider "aws" {
  region = "ap-south-1"
}
resource "aws_instance" "example" {
  ami                    = "ami-02eb7a4783e7e9317"
  instance_type          = "t2.micro"
  key_name               = "Kube-key"
  vpc_security_group_ids = [aws_security_group.allow_ssh_http_https.id]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("Kube-key.pem")
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline =  [
        "sudo apt-get update",
        "wget 'https://github.com/tenable/terrascan/releases/download/v1.18.1/terrascan_1.18.1_Linux_x86_64.tar.gz' &&  tar -xvf terrascan_1.18.1_Linux_x86_64.tar.gz",
        "sudo mv terrascan /usr/local/bin",
        "terrascan -h"       
    ]
  }
tags = {
    Name = "terraform"
  }
}

