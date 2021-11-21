resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_user" "s3" {
  name = "s3"
}

resource "aws_iam_access_key" "s3" {
  user = aws_iam_user.s3.name
}

data "aws_iam_policy" "s3" {
  name = "AmazonS3FullAccess"
}

resource "aws_iam_user_policy_attachment" "s3" {
  user       = aws_iam_user.s3.name
  policy_arn = data.aws_iam_policy.s3.arn
}

resource "aws_s3_bucket_public_access_block" "s3" {
  bucket              = aws_s3_bucket.bucket.id
  block_public_acls   = true
  block_public_policy = true
}