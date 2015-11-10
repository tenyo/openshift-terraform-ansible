output "master_ip" {
  value = "${aws_instance.ose-master.public_ip}"
}
output "node_ips" {
  value = "${join(",", aws_instance.ose-node.*.public_ip)}"
}
