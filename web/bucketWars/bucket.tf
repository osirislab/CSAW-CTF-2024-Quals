#####################
#### USE LATEST PLUGIN
#####################
terraform {  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.01"
    }
  }
  required_version = ">= 1.4.6"
}

variable "bucket_name" {}
variable "flag_bucket_name" {}
variable "tag" {}

provider "aws" {
  region = "us-east-2"  
   default_tags {
    tags = {
      "${var.tag}" = "" 
    }
  }
}



#####################################################
#### BUCKET 1 SETUP -- NEED TO RUN 2x to apply POLICY
#####################################################
resource "aws_s3_bucket" "bucketwars_s3_bucket" {
  bucket = "${var.bucket_name}"
  force_destroy = true
}


###########################
#### BUCKET 1 -- ENABLE ACL
###########################
resource "aws_s3_bucket_ownership_controls" "bucketwars_s3_bucket" {
  bucket = aws_s3_bucket.bucketwars_s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucketwars_s3_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.bucketwars_s3_bucket]

  bucket = aws_s3_bucket.bucketwars_s3_bucket.id
  acl    = "private"
}



##################################
#### BUCKET 1 -- ENABLE VERSIONING
##################################
resource "aws_s3_bucket_versioning" "bucketwars_s3_bucket_versioning" {
  bucket = aws_s3_bucket.bucketwars_s3_bucket.id

  versioning_configuration {
    status = "Enabled"  # Specify "Suspended" to disable versioning
  }
}


##################################
#### BUCKET 1 -- SET AS STATIC FILE
##################################
resource "aws_s3_bucket_website_configuration" "bucketwars_s3_bucket_website-config" {
bucket = aws_s3_bucket.bucketwars_s3_bucket.bucket
index_document {
    suffix = "index.html"
  }
error_document {
    key = "https://s3.us-east-2.amazonaws.com/${var.bucket_name}/404.jpg"
  }
}

##################################
#### BUCKET 1 -- ADD SITE_FILES
##################################
resource "aws_s3_object" "site_files" {
    for_each        = fileset("site_files/", "*")
    bucket          = aws_s3_bucket.bucketwars_s3_bucket.bucket
    key             = each.value
    source          = "site_files/${each.value}"
    content_type    = "text/html"
    etag            = "${filemd5("site_files/${each.value}")}"
    #acl            = "public-read"
}

resource "aws_s3_object" "css_1" {
  bucket          = aws_s3_bucket.bucketwars_s3_bucket.bucket 
  key             = "styles.css"
  source          = "site_files/styles.css"
  content_type    = "css"
}

resource "aws_s3_object" "css_2" {
  bucket          = aws_s3_bucket.bucketwars_s3_bucket.bucket 
  key             = "styles.css"
  source          = "site_files/styles.css"
  content_type    = "css"
}

resource "aws_s3_object" "jpeg" {
  bucket          = aws_s3_bucket.bucketwars_s3_bucket.bucket 
  key             = "404.jpg"
  source          = "site_files/404.jpg"
  content_type    = "jpg"
}



#####################################################
#### BUCKET 2 SETUP -- NEED TO RUN 2x to apply POLICY
#####################################################
resource "aws_s3_bucket" "bucketwars_s3_flag_bucket" {
  bucket = "${var.flag_bucket_name}"
  force_destroy = true
}


###########################
#### BUCKET 2 -- ENABLE ACL
###########################
resource "aws_s3_bucket_ownership_controls" "bucketwars_s3_flag_bucket" {
  bucket = aws_s3_bucket.bucketwars_s3_flag_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucketwars_s3_flag_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.bucketwars_s3_flag_bucket]

  bucket = aws_s3_bucket.bucketwars_s3_flag_bucket.id
  acl    = "private"
}


###################################
#### BUCKET 2 -- ADD STATIC FILE
###################################
resource "aws_s3_object" "flag_file" {
  bucket          = aws_s3_bucket.bucketwars_s3_flag_bucket.bucket 
  key             = "sand-pit-1345726_640.jpg"
  source          = "sand-pit-1345726_640.jpg"
  content_type    = "image/jpeg"
}



##################################
#### BUCKET 1 -- ADD POLICY (WILL WORK AFTER BUCKETS MANUALLY MADE PUBLIC)
##################################
resource "aws_s3_bucket_policy" "bucketwars_s3_bucket_policy" {
  bucket = aws_s3_bucket.bucketwars_s3_bucket.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ],
            "Resource": "arn:aws:s3:::${var.bucket_name}/*"
        },
        {
            "Sid": "PublicListBucketVersions",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:ListBucketVersions",
            "Resource": "arn:aws:s3:::${var.bucket_name}"
        }
    ]
}
EOF
}


##########################################################################
#### BUCKET 2 -- ADD POLICY (WILL WORK AFTER BUCKETS MANUALLY MADE PUBLIC)
##########################################################################
resource "aws_s3_bucket_policy" "bucketwars_s3_flag_bucket_policy" {
  bucket = aws_s3_bucket.bucketwars_s3_flag_bucket.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject2",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.flag_bucket_name}/*"
        },
        {
            "Sid": "AllowSSLRequestsOnly",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.flag_bucket_name}",
                "arn:aws:s3:::${var.flag_bucket_name}/*"
             ],
            "Condition": {
                "Bool": {
                     "aws:SecureTransport": "false"

                }
            }
        }
    ]
}
EOF
}




