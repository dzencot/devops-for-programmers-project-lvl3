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

resource "datadog_monitor" "foo" {
  name               = "devops-project-lvl3 HTTP Alert! {{host.name}}"
  type               = "service check"
  message            = "Monitor triggered. Notify: @dzencot@gmail.com"

  query = "\"http.can_connect\".over(\"instance:application_health_check_status\").by(\"host\",\"instance\",\"url\").last(2).count_by_status()"

  notify_no_data    = true
  renotify_interval = 60

  notify_audit = false
  timeout_h    = 60
}
