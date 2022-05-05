// provider:cloud APIの明示
provider "aws" {
  region = "ap-northeast-1"
}

# module "web_server" {
#   source        = "./http_server"
#   instance_type = "t3.micro"
# }
# output "public_dns" {
#   value = module.web_server.public_dns
# }

#### IAM
# data "aws_iam_policy_document" "allow_description_regions" {
#   // リージョン一覧を取得
#   statement {
#     effect = "Allow"
#     actions   = ["ec2:DescribeRegions"]
#     resources = ["*"]
#   }
# }
# module "describe_regions_for_ec2" {
#   source = "./iam_role"
#   name = "describe-regions-for-ec2"
#   identifier = "ec2.amazonaws.com"
#   policy = data.aws_iam_policy_document.allow_description_regions.json
# }


### S3
resource "aws_s3_bucket" "private" {
  bucket = "private-pragmatic-terraform20220505173053"

  ////// Deprecated
  // NOTE: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#using-versioning
  # versioning {
  #   enabled= true
  # }

  ////// Deprecated
  // NOTE: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#enable-default-server-side-encryption
  # server_side_encryption_configuration {
  #   rule {
  #     apply_serverside_encryption_by_default{
  #       sse_algorithm = "AES256"
  #     }
  #   }
  # }
}

resource "aws_s3_bucket_versioning" "private" {
  bucket = aws_s3_bucket.private.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "private" {
  bucket = aws_s3_bucket.private.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

// パブリックブロックアクセス
// 予期しないオブジェクトの公開防止
resource "aws_s3_bucket_public_access_block" "private" {
  bucket                  = aws_s3_bucket.private.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "public" {
  bucket = "public-pragmatic-terraform20220505173317"
}

resource "aws_s3_bucket_acl" "punlic_acl" {
  bucket = aws_s3_bucket.public.id
  acl    = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "public-cors" {
  bucket = aws_s3_bucket.public.bucket

  cors_rule {
    allowed_origins = ["https://example.com"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "alb_log" {
  bucket = "alb-log-progmatic-terraform20220505185403"
}

resource "aws_s3_bucket_lifecycle_configuration" "alb-log-lc" {
  bucket = aws_s3_bucket.alb_log.bucket

  rule {
    id = aws_s3_bucket.alb_log.id
    status = "Enabled"
    expiration {
      days = "180"
    }
  }
}