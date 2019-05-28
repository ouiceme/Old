output "ip_ec2" {
  value = "${aws_instance.web.public_ip}"
}
