#############################################################################
# State Locking for EKS cluster
resource "aws_dynamodb_table" "dev-ekscluster" {
  name = "dev-ekscluster"
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# State Locking for Bastion Host
resource "aws_dynamodb_table" "dev-bastion-host" {
  name = "dev-bastion-host"
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# State Locking for Load Balancer Controller
resource "aws_dynamodb_table" "dev-aws-lbc" {
  name = "dev-aws-lbc"
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# State Locking for external DNS
resource "aws_dynamodb_table" "dev-aws-externaldns" {
  name = "dev-aws-externaldns"
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# State Locking for CloudWatch logs and metrics
resource "aws_dynamodb_table" "dev-eks-cloudwatch-agent" {
  name = "dev-eks-cloudwatch-agent"
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# State Locking for Applications
resource "aws_dynamodb_table" "dev-aws-lbc-ingress" {
  name = "dev-aws-lbc-ingress"
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}


#############################################################################
# Jenkins build recorder
resource "aws_dynamodb_table" "build_info" {
  name = "jenkins-build-info"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "application"
  range_key = "timestamp"

  attribute {
    name = "application"
    type = "S"
  }
  attribute {
    name = "timestamp"
    type = "S"
  }
}

# Jenkins deploy recorder
resource "aws_dynamodb_table" "release_info" {
  name         = "jenkins-release-info"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "version"
  range_key    = "module"

  attribute {
    name = "version"
    type = "S"
  }
  attribute {
    name = "module"
    type = "S"
  }
}
