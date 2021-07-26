output "servers" {
  value = aws_instance.servers.*.public_ip
}

output "load_balancer" {
  value = module.elb_http
}
