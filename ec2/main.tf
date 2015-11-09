variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "keypair" {default = "osekeypair"}
variable "master_instance_type" {default = "t2.small"}
variable "node_instance_type" {default = "t2.small"}
variable "aws_availability_zone" {default = "us-east-1"}
variable "aws_region" {default = "us-east-1b"}
variable "aws_ami" {default = "ami-61bbf104"}
variable "security_group" {default = "openshift-sg"}
variable "ebs_root_block_size" {default = "50"}
variable "num_nodes" { default = "2" }
variable "ssh_user" { default = "ec2-user" }

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

resource "aws_instance" "ose-master" {
    ami = "${var.aws_ami}"
    instance_type = "${var.master_instance_type}"
    security_groups = [ "${var.security_group}" ]
    availability_zone = "${var.aws_availability_zone}"
    key_name = "${var.keypair}"
    tags {
        Name = "openshift-master"
        role = "masters"
        sshUser = "${var.ssh_user}"
    }
	root_block_device = {
		volume_type = "gp2"
		volume_size = "${var.ebs_root_block_size}"
	}
}

resource "aws_instance" "ose-node" {
    count = "${var.num_nodes}"
    ami = "${var.aws_ami}"
    instance_type = "${var.node_instance_type}"
    security_groups = [ "${var.security_group}" ]
    availability_zone = "${var.aws_availability_zone}"
    key_name = "${var.keypair}"
    tags {
        Name = "${concat("openshift-node", count.index)}"
        role = "nodes"
        sshUser = "${var.ssh_user}"
    }
	root_block_device = {
		volume_type = "gp2"
		volume_size = "${var.ebs_root_block_size}"
	}
}

resource "aws_security_group" "openshift-sg" {
  name = "${var.security_group}"
  description = "OpenShift security group"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 4789
      to_port = 4789
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 8443
      to_port = 8443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 10250
      to_port = 10250
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

