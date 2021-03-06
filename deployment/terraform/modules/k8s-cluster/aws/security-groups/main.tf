//api elb security group
resource "aws_security_group" "api-elb" {
  name = "api-elb.${var.haystack_cluster_name}"
  vpc_id = "${var.aws_vpc_id}"
  description = "Security group for api ELB"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Product = "Haystack"
    Component = "K8s"
    ClusterName = "${var.haystack_cluster_name}"
    Role = "${var.haystack_cluster_name}-k8s-masters-elb"
    Name = "${var.haystack_cluster_name}-k8s-masters-elb"
  }

}


//node elb security group
resource "aws_security_group" "nodes-elb" {
  name = "nodes-elb.${var.haystack_cluster_name}"
  vpc_id = "${var.aws_vpc_id}"
  description = "Security group for nodes ELB"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Product = "Haystack"
    Component = "K8s"
    ClusterName = "${var.haystack_cluster_name}"
    Role = "${var.haystack_cluster_name}-k8s-nodes-elb"
    Name = "${var.haystack_cluster_name}-k8s-nodes-elb"

  }
}


//node elb security group
resource "aws_security_group" "monitoring-elb" {
  name = "monitoring-elb.${var.haystack_cluster_name}"
  vpc_id = "${var.aws_vpc_id}"
  description = "Security group for nodes ELB"
  ingress {
    from_port = 2003
    to_port = 2003
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Product = "Haystack"
    Component = "K8s"
    ClusterName = "${var.haystack_cluster_name}"
    Role = "${var.haystack_cluster_name}-k8s-monitoring-elb"
    Name = "${var.haystack_cluster_name}-k8s-monitoring-elb"

  }
}

//node instance security group

resource "aws_security_group" "nodes" {
  name = "nodes.${var.haystack_cluster_name}"
  vpc_id = "${var.aws_vpc_id}"
  description = "Security group for nodes"

  tags = {
    Product = "Haystack"
    Component = "K8s"
    ClusterName = "${var.haystack_cluster_name}"
    Role = "${var.haystack_cluster_name}-k8s-nodes"
    Name = "${var.haystack_cluster_name}-k8s-nodes"
  }
}


resource "aws_security_group_rule" "all-master-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes.id}"
  source_security_group_id = "${aws_security_group.masters.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}
resource "aws_security_group_rule" "all-node-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes.id}"
  source_security_group_id = "${aws_security_group.nodes.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"]
}


resource "aws_security_group_rule" "reverse_proxy-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes.id}"
  source_security_group_id = "${aws_security_group.nodes-elb.id}"
  from_port = "${var.reverse_proxy_port}"
  to_port = "${var.reverse_proxy_port}"
  protocol = "tcp"
}

resource "aws_security_group_rule" "graphite_elb-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes.id}"
  source_security_group_id = "${aws_security_group.monitoring-elb.id}"
  from_port = "${var.graphite_node_port}"
  to_port = "${var.graphite_node_port}"
  protocol = "tcp"
}

resource "aws_security_group_rule" "node-egress" {
  type = "egress"
  security_group_id = "${aws_security_group.nodes.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [
    "0.0.0.0/0"]
}



//master instance security group

resource "aws_security_group" "masters" {
  name = "masters.${var.haystack_cluster_name}"
  vpc_id = "${var.aws_vpc_id}"
  description = "Security group for masters"

  tags = {
    Product = "Haystack"
    Component = "K8s"
    ClusterName = "${var.haystack_cluster_name}"
    Role = "${var.haystack_cluster_name}-k8s-masters"
    Name = "${var.haystack_cluster_name}-k8s-masters"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters.id}"
  source_security_group_id = "${aws_security_group.masters.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}
resource "aws_security_group_rule" "all-node-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters.id}"
  source_security_group_id = "${aws_security_group.nodes.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-elb-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters.id}"
  source_security_group_id = "${aws_security_group.api-elb.id}"
  from_port = 443
  to_port = 443
  protocol = "tcp"
}

resource "aws_security_group_rule" "master-egress" {
  type = "egress"
  security_group_id = "${aws_security_group.masters.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [
    "0.0.0.0/0"]
}


