resource "aws_security_group" "sg" {
  name        = "${var.project}-cluster-sg"
  description = "Allow ssh http inbound traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 81
    to_port          = 81
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
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
    Name = "${var.project}-Public-sg"
  }
}

# # Security group for public subnet
# resource "aws_security_group" "public_sg" {
#   name   =  "${var.project}-Public-sg"
#   vpc_id = aws_vpc.this.id

#   tags = {
#     Name = "${var.project}-Public-sg"
#   }
# }

# # Security group traffic rules
# resource "aws_security_group_rule" "sg_ingress_public_443" {
#   security_group_id = aws_security_group.public_sg.id
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
# }


# # Security group for data plane
# resource "aws_security_group" "data_plane_sg" {
#   name   =  "${var.project}-Worker-sg"
#   vpc_id = aws_vpc.this.id

#   tags = {
#     Name = "${var.project}-Worker-sg"
#   }
# }

# # Security group traffic rules
# resource "aws_security_group_rule" "nodes" {
#   description       = "Allow nodes to communicate with each other"
#   security_group_id = aws_security_group.data_plane_sg.id
#   type              = "ingress"
#   from_port         = 0
#   to_port           = 65535
#   protocol          = "-1"
#   cidr_blocks       = flatten([cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 0), cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 1), cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 2), cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 3)])
# }

# resource "aws_security_group_rule" "nodes_inbound" {
#   description       = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
#   security_group_id = aws_security_group.data_plane_sg.id
#   type              = "ingress"
#   from_port         = 1025
#   to_port           = 65535
#   protocol          = "tcp"
#   cidr_blocks       = flatten([cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 2), cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 3)])
# }

# resource "aws_security_group_rule" "node_outbound" {
#   security_group_id = aws_security_group.data_plane_sg.id
#   type              = "egress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
# }

# # Security group for control plane
# resource "aws_security_group" "control_plane_sg" {
#   name   = "${var.project}-ControlPlane-sg"
#   vpc_id = aws_vpc.this.id

#   tags = {
#     Name = "${var.project}-ControlPlane-sg"
#   }
# }

# # Security group traffic rules
# resource "aws_security_group_rule" "control_plane_inbound" {
#   security_group_id = aws_security_group.control_plane_sg.id
#   type              = "ingress"
#   from_port         = 0
#   to_port           = 65535
#   protocol          = "tcp"
#   cidr_blocks       = flatten([cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 0), cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 1), cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 2), cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 3)])
# }

# resource "aws_security_group_rule" "control_plane_outbound" {
#   security_group_id = aws_security_group.control_plane_sg.id
#   type              = "egress"
#   from_port         = 0
#   to_port           = 65535
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
# }


# # EKS Cluster Security Group
# resource "aws_security_group" "eks_cluster" {
#   name        = "${var.project}-cluster-sg"
#   description = "Cluster communication with worker nodes"
#   vpc_id      = aws_vpc.this.id

#   tags = {
#     Name = "${var.project}-cluster-sg"
#   }
# }

# resource "aws_security_group_rule" "cluster_inbound" {
#   description              = "Allow worker nodes to communicate with the cluster API Server"
#   from_port                = 443
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.eks_cluster.id
#   source_security_group_id = aws_security_group.eks_nodes.id
#   to_port                  = 443
#   type                     = "ingress"
# }

# resource "aws_security_group_rule" "cluster_outbound" {
#   description              = "Allow cluster API Server to communicate with the worker nodes"
#   from_port                = 1024
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.eks_cluster.id
#   source_security_group_id = aws_security_group.eks_nodes.id
#   to_port                  = 65535
#   type                     = "egress"
# }