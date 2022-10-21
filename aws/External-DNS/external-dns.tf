#############################################################################
# Install External-DNS using HELM
resource "helm_release" "external_dns" {
  depends_on = [aws_iam_role.externaldns_iam_role]            
  name       = "external-dns"

  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace = "default"     

  set {
    name = "image.repository"
    value = "k8s.gcr.io/external-dns/external-dns" 
  }       

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.externaldns_iam_role.arn}"
  }

  set {
    name  = "provider" # Default is aws
    value = "aws"
  }    

  set {
    name  = "policy" # Default is "upsert-only" which means DNS records will not get deleted even equivalent Ingress resources are deleted
    value = "sync"   # "sync" will ensure that when ingress resource is deleted, equivalent DNS record in Route53 will get deleted
  }    
}


#############################################################################
# External-DNS IAM Policy 
resource "aws_iam_policy" "externaldns_iam_policy" {
  name        = "${local.name}-AllowExternalDNSUpdates"
  path        = "/"
  description = "External DNS IAM Policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource": [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        "Resource": [
          "*"
        ]
      }
    ]
  })
}

# External-DNS IAM Role 
resource "aws_iam_role" "externaldns_iam_role" {
  name = "${local.name}-externaldns-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn}:aud": "sts.amazonaws.com",            
            "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn}:sub": "system:serviceaccount:default:external-dns"
          }
        }
      },
    ]
  })

  tags = {
    tag-key = "AllowExternalDNSUpdates"
  }
}

# Associate External-DNS IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "externaldns_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.externaldns_iam_policy.arn 
  role       = aws_iam_role.externaldns_iam_role.name
}


#############################################################################
# Helm Release Outputs
output "externaldns_helm_metadata" {
  description = "Metadata Block outlining status of the deployed release."
  value = helm_release.external_dns.metadata
}


#############################################################################
