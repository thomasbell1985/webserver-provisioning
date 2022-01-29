
output "instance_ids" {
  description = "ID of the EC2 instance"
  value = {
    for k, v in aws_instance.web_server : k => v.id
  }
}

output "webserver_ips" {
  description = "Public IP address of the EC2 instance"
  value = [
    for k, v in aws_instance.web_server : v.public_ip
  ]
}
