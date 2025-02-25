provider "aws" {
  region = "-----------" #eu-central-1
}

# VPC Creation
resource "aws_vpc" "trans_eks_vpc" {
  cidr_block = "--------" #10.0.0.0/16
}

# Subnet 1
resource "aws_subnet" "trans_public1" {
  vpc_id                  = aws_vpc.trans_eks_vpc.id
  cidr_block              = "-------" #10.0.1.0/24
  map_public_ip_on_launch = true
  availability_zone       = "--------" #eu-central-1a
}

# Subnet 2
resource "aws_subnet" "trans_public2" {
  vpc_id                  = aws_vpc.trans_eks_vpc.id
  cidr_block              = "--------" #10.0.2.0/24
  map_public_ip_on_launch = true
  availability_zone       = "---------" #eu-central-1b
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "trans_eks_role" {
  name = "trans-eks-cluster-role" 

  assume_role_policy =<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach IAM policy to EKS Cluster Role
resource "aws_iam_role_policy_attachment" "trans_eks_policy" {
  role       = aws_iam_role.trans_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment"
"trans_eks_cloudwatch_policy"{
  role   = aws_iam_role.trans_eks_role.name
  policy_arn = "--------"
}
# IAM Role for Node Group
resource "aws_iam_role" "trans_node_role" {
  name = "trans-eks-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach IAM policy to Node Role
resource "aws_iam_role_policy_attachment" "node_policy" {
  role       = aws_iam_role.trans_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment"
"trans_node_cloudwatch_policy"{
  role   = aws_iam_role.trans_node_role.name
  policy_arn = "--------"
}

# EKS Cluster Creation
resource "trans_eks_cluster" "dev_ai" {
  name     = "dev-ai"
  role_arn = aws_iam_role.trans_eks_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.public1.id, aws_subnet.public2.id]
  }
# Enable CloudWatch Logging  
enabled_cluster_logs_types = ["api", "audit", "authenticator", "ControllerManager", "scheduler"]

  depends_on = [aws_iam_role_policy_attachment.trans_eks_policy, aws_iam_role_policy_attachment.trans_eks_cloudwatch_policy]
}

# EKS Node Group Creation
resource "aws_eks_node_group" "dev_ai_nodes" {
  cluster_name    = trans_eks_cluster.dev_ai.name
  node_group_name = "dev-ai-nodes"
  node_role_arn   = aws_iam_role.trans_node_role.arn
  subnet_ids      = [aws_subnet.public1.id, aws_subnet.public2.id]
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }
depends_on = [aws_iam_role_policy_attachment.trans_node_policy, aws_iam_role_policy_attachment.trans_node_cloudwatch_policy]
}
