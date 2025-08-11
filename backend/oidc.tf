data "aws_iam_openid_connect_provider" "llm_github" {
  url = "https://token.actions.githubusercontent.com"
}


resource "aws_iam_role" "llm_inference_api_github_actions" {
  name = "llm-inference-api-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "${data.aws_iam_openid_connect_provider.llm_github.arn}"
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
          AWS = "arn:aws:iam::${var.account_id}:user/llm_inference"
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
      # --- EKS ---
      {
        Effect = "Allow",
        Action = [
          "eks:ListIdentityProviderConfigs", "eks:ListAddons", "eks:ListClusters", "eks:ListUpdates",
          "eks:ListNodegroups", "eks:DescribeCluster", "eks:DescribeNodegroup", "eks:DescribeAddonVersions",
          "eks:UpdateClusterConfig", "eks:DescribeUpdate", "eks:CreateCluster", "eks:CreateNodegroup",
          "eks:DeleteCluster", "eks:DeleteNodegroup", "eks:CreateAccessEntry", "eks:CreateAccessPolicyAssociation",
          "eks:DeleteAccessEntry", "eks:DescribeAccessEntry", "eks:AssociateAccessPolicy",
          "eks:ListAssociatedAccessPolicies", "eks:DisassociateAccessPolicy", "eks:AccessKubernetesApi"
        ],
        Resource = "*"
      },

      # --- ECR ---
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken", "ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage", "ecr:PutImage", "ecr:DescribeRepositories", "ecr:ListTagsForResource",
          "ecr:CreateRepository", "ecr:TagResource", "ecr:InitiateLayerUpload", "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        Resource = "*"
      },

      # --- TF backend S3/DDB ---
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket", "s3:DeleteObject"],
        Resource = [
          "arn:aws:s3:::llm-inference-api-terraform-state",
          "arn:aws:s3:::llm-inference-api-terraform-state/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:DeleteItem", "dynamodb:DescribeTable"],
        Resource = "arn:aws:dynamodb:us-east-1:831274730062:table/llm-inference-api-terraform-locks"
      },

      # --- EC2 for networking ---
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeVpcs", "ec2:DescribeSubnets", "ec2:DescribeSecurityGroups", "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways", "ec2:DescribeVpcAttribute", "ec2:DescribeAddresses",
          "ec2:DescribeAddressesAttribute", "ec2:DescribeNatGateways", "ec2:CreateVpc", "ec2:CreateSubnet",
          "ec2:CreateInternetGateway", "ec2:CreateRouteTable", "ec2:CreateRoute", "ec2:CreateSecurityGroup",
          "ec2:CreateNatGateway", "ec2:AttachInternetGateway", "ec2:DeleteInternetGateway", "ec2:AllocateAddress",
          "ec2:AssociateRouteTable", "ec2:ModifyVpcAttribute", "ec2:RevokeSecurityGroupEgress",
          "ec2:DescribeNetworkInterfaces", "ec2:DeleteSecurityGroup", "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress", "ec2:DescribeKeyPairs", "ec2:CreateTags"
        ],
        Resource = "*"
      },

      # --- IAM ---
      {
        Effect = "Allow",
        Action = [
          "iam:GetRole", "iam:GetRolePolicy", "iam:GetOpenIDConnectProvider", "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies", "iam:ListInstanceProfilesForRole", "iam:DetachRolePolicy",
          "iam:DeleteRole", "iam:DeleteOpenIDConnectProvider", "iam:CreateRole", "iam:PassRole", "iam:TagRole",
          "iam:CreateServiceLinkedRole", "iam:ListRoles"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:AttachRolePolicy", "iam:CreatePolicy", "iam:PutRolePolicy", "iam:DeleteRolePolicy", "iam:DeletePolicy",
          "iam:DeletePolicyVersion", "iam:GetPolicy", "iam:GetPolicyVersion", "iam:ListPolicyVersions",
          "iam:CreateOpenIDConnectProvider"
        ],
        Resource = "*"
      },

      # --- SSM Read ---
      {
        Effect   = "Allow",
        Action   = ["ssm:Describe*", "ssm:Get*", "ssm:List*"],
        Resource = "*"
      },

      # --- Artifacts bucket  ---
      {
        Effect   = "Allow",
        Action   = ["s3:CreateBucket", "s3:PutBucketTagging", "s3:GetBucketLocation"],
        Resource = "arn:aws:s3:::llm-inference-api-artifacts"
      },
      {
        Effect = "Allow",
        Action = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::llm-inference-api-artifacts",
          "arn:aws:s3:::llm-inference-api-artifacts/*"
        ]
      },

      # ===  Frontend bucket admin  ===
      {
        Sid    = "FrontendBucketAdmin",
        Effect = "Allow",
        Action = [
          "s3:CreateBucket",
          "s3:PutBucketPolicy",
          "s3:GetBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:PutBucketPublicAccessBlock",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:PutBucketOwnershipControls",
          "s3:PutBucketTagging",
          "s3:GetBucketAcl",
          "s3:GetBucketCORS",
          "s3:GetBucketWebsite",
          "s3:GetBucketVersioning",
          "s3:GetBucketAccelerateConfiguration",
          "s3:GetAccelerateConfiguration",
          "s3:GetBucketRequestPayment",
          "s3:GetBucketLogging",
          "s3:GetLifecycleConfiguration",
          "s3:GetReplicationConfiguration",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketObjectLockConfiguration",
          "s3:GetBucketTagging",
          "s3:DeleteBucket",
          "s3:GetBucketPublicAccessBlock"

        ],
        Resource = "arn:aws:s3:::llm-inference-api-frontend"
      },
      {
        Sid    = "FrontendObjectsRW",
        Effect = "Allow",
        Action = [
          "s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:PutObjectTagging",
          "s3:ListBucketMultipartUploads", "s3:AbortMultipartUpload", 
        ],
        Resource = "arn:aws:s3:::llm-inference-api-frontend/*"
      },

      # ===  CloudFront OAC / Distribution / Invalidation ===
      {
        Sid    = "CloudFrontManage",
        Effect = "Allow",
        Action = [
          "cloudfront:CreateOriginAccessControl", "cloudfront:GetOriginAccessControl",
          "cloudfront:ListOriginAccessControls", "cloudfront:UpdateOriginAccessControl",
          "cloudfront:DeleteOriginAccessControl",

          "cloudfront:CreateDistribution", "cloudfront:GetDistribution", "cloudfront:GetDistributionConfig",
          "cloudfront:UpdateDistribution", "cloudfront:DeleteDistribution", "cloudfront:ListDistributions",

          "cloudfront:CreateInvalidation", "cloudfront:GetInvalidation", "cloudfront:ListInvalidations"
        ],
        Resource = "*"
      }
    ]
  })
}