resource "aws_iam_role" "node" {
  name = "t8s-node-${ var.cluster["cluster-id"] }"

  assume_role_policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${ data.aws_caller_identity.current.account_id }:role/t8s-node-${ var.cluster["cluster-id"] }"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOS
}

resource "aws_iam_instance_profile" "node" {
  name = "t8s-node-${ var.cluster["cluster-id"] }"

  role = "${ aws_iam_role.node.name }"
}

resource "aws_iam_role_policy" "node" {
  name = "t8s-node-${ var.cluster["cluster-id"] }"

  role = "${ aws_iam_role.node.id }"

  policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [ "${ var.s3-bucket-arn }/*" ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
        ],
        "Resource": [
            "arn:aws:logs:*:*:log-group:*",
            "arn:aws:logs:*:*:log-group:*:log-stream:*"
        ]
    }
  ]
}
EOS
}

resource "null_resource" "dummy_dependency" {
  depends_on = [
    "aws_iam_role.node",
    "aws_iam_role_policy.node",
    "aws_iam_instance_profile.node",
  ]
}
