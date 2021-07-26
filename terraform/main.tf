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

resource "aws_instance" "servers" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  count = var.number_of_instances

  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.security_group.id]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "~> 2.0"

  name = "elb-devops3"

  subnets         = data.aws_subnet_ids.all.ids
  security_groups = [data.aws_security_group.default.id]
  internal        = false

  listener = [
    {
      instance_port     = "80"
      instance_protocol = "http"
      lb_port           = "80"
      lb_protocol       = "http"
    }
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = {
    Name = "devops3"
  }

  # ELB attachments
  number_of_instances = var.number_of_instances
  instances           = aws_instance.servers.*.id
}

resource "aws_security_group" "security_group" {
  name = "security_group"

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
  name    = "devops-project-lvl3 HTTP Alert! {{host.name}}"
  type    = "service check"
  message = "Monitor triggered. Notify: @dzencot@gmail.com"

  query = "\"http.can_connect\".over(\"instance:application_health_check_status\").by(\"host\",\"instance\",\"url\").last(2).count_by_status()"

  notify_no_data    = true
  renotify_interval = 60

  notify_audit = false
  timeout_h    = 60
}
