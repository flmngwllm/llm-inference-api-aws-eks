resource "aws_iam_openid_connect_provider" "llm_github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}


resource "aws_iam_role" "llm_inference_api_github_actions" {
  name = "llm-inference-api-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${var.account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:flmngwllm/llm-inference-api-aws-eks:*"
          },
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:user/llm-inference"
        },
        Action = "sts:AssumeRole"
      }

    ]
  })
}

resource "aws_iam_role_policy" "llm_github_actions_policy" {
  name = "llm-github-actions-policy"
  role = aws_iam_role.llm_inference_api_github_actions.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "eks:ListIdentityProviderConfigs",
          "eks:ListAddons",
          "eks:ListClusters",
          "eks:ListUpdates",
          "eks:ListNodegroups",
          "eks:DescribeCluster",
          "eks:DescribeNodegroup",
          "eks:DescribeAddonVersions",
          "eks:UpdateClusterConfig",
          "eks:DescribeUpdate",
          "eks:CreateCluster",
          "eks:CreateNodegroup",
          "eks:DeleteCluster",
          "eks:DeleteNodegroup",
          "eks:CreateAccessEntry",
          "eks:CreateAccessPolicyAssociation",
          "eks:DeleteAccessEntry",
          "eks:DescribeAccessEntry",
          "eks:AssociateAccessPolicy",
          "eks:ListAssociatedAccessPolicies",
          "eks:DisassociateAccessPolicy",
          "eks:AccessKubernetesApi"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:DescribeRepositories",
          "ecr:ListTagsForResource",
          "ecr:CreateRepository",
          "ecr:TagResource",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",



        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::llm-inference-api-terraform-state",
          "arn:aws:s3:::llm-inference-api-terraform-state/*"
        ]
      },
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:dynamodb:us-east-1:831274730062:table/llm-inference-api-terraform-locks"
      },
      {
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeAddresses",
          "ec2:DescribeAddressesAttribute",
          "ec2:DescribeNatGateways",
          "ec2:CreateVpc",
          "ec2:CreateSubnet",
          "ec2:CreateInternetGateway",
          "ec2:CreateRouteTable",
          "ec2:CreateRoute",
          "ec2:CreateSecurityGroup",
          "ec2:CreateNatGateway",
          "ec2:AttachInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:AllocateAddress",
          "ec2:AssociateRouteTable",
          "ec2:ModifyVpcAttribute",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:DescribeKeyPairs",
          "ec2:CreateTags"

        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:GetOpenIDConnectProvider",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:DetachRolePolicy",
          "iam:DeleteRole",
          "iam:DeleteOpenIDConnectProvider",
          "iam:CreateRole",
          "iam:PassRole",
          "iam:TagRole",
          "iam:CreateServiceLinkedRole",
          "iam:ListRoles"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "iam:AttachRolePolicy",
          "iam:CreatePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:DeletePolicy",
          "iam:DeletePolicyVersion",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:CreateOpenIDConnectProvider"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:Describe*",
          "ssm:Get*",
          "ssm:List*"
        ],
        "Resource" : "*"
      },
      {
        "Effect": "Allow",
        "Action": [
        "s3:CreateBucket"
      ],
  "Resource": "arn:aws:s3:::llm-inference-api-artifacts"
    },
    {
  "Effect": "Allow",
  "Action": [
    "s3:PutObject",
    "s3:GetObject",
    "s3:ListBucket"
  ],
  "Resource": "arn:aws:s3:::llm-inference-api-artifacts/*"
      }
    ]
  })
}