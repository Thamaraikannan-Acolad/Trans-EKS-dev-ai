provider "aws" {
    region = "us-west-2"
}

resource "aws_eks_cluster" "my_eks_cluster" {
    name     = "my-eks-cluster"
    role_arn = aws_iam_role.eks_cluster_role.arn

    vpc_config {
        subnet_ids = aws_subnet.eks_subnet[*].id
    }
}

resource "aws_iam_role" "eks_cluster_role" {
    name = "eks_cluster_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
    role       = aws_iam_role.eks_cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_vpc" "eks_vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "eks_subnet" {
    count             = 2
    vpc_id            = aws_vpc.eks_vpc.id
    cidr_block        = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
    availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

data "aws_availability_zones" "available" {}