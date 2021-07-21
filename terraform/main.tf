variable "aws_key_name" {
  default = "my-key"
}

variable "ssh_pub_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKT74P8ocb51cFxYNOdE5VecQ74sC0GYU9tNEgFKL+gH4fyFMo5CLLEiyo5yjznDPZdaqIiQImjwsaxLZSB7ZZRxjlbYXFKE7DBnF40D9HPF+G29XhbNnE9f7pf6HJcMSbH8irA8Hbhb5xvvW95yfv81KCLWy/SreR6RgxctRkZKjgES5Xjr/VcG7wm6rIT52PEnL6glcDR5Rbr4CWERS0PzJN8D+8IW3cdW67+qpzgkuPVGOLF1DWvIcv0CF+oQgN/bI1C2zE43GmT6IBslkdc2tFoC1HIdhsWHJ0sUtgpGMUzVp05vOLNnGmpRvj0XT0DssEGDum3z5YI8lvniYt ivan@ivan-debian"
}

resource "aws_key_pair" "deployer" {
  key_name   = var.aws_key_name
  public_key = var.ssh_pub_key
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.security_group.id]
}

resource "aws_security_group" "security_group" {
  name        = "security_group"

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "app"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "security_group"
  }
}

resource "datadog_synthetics_test" "check_app" {
  type    = "browser"
  subtype = "http"
  request_definition {
    method = "GET"
    url    = "http://${aws_instance.server.public_ip}"
  }
  device_ids = ["laptop_large"]
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900

    retry {
      count    = 2
      interval = 300
    }

    monitor_options {
      renotify_interval = 100
    }
  }
  name    = "Test"
  message = "Alert"
  tags    = ["foo:bar", "foo", "env:test"]

  status = "live"
}
