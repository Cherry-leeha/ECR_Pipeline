resource "aws_iam_role" "codepipeline_role" {
  name = "terraform-codepipeline"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}



resource "aws_iam_policy" "codepipeline_policy" {
    description = "Codepipeline Execution Policy"
    policy = <<E0F
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:Getobject", "s3:GetObjectVersion", "s3:PutObject",
                "s3:GetBucketVersioning"
            ],
            "Effect": "Allow",
            "Resource": "${aws_s3_bucket.artifact_bucket.arn}/*"
        },
        {
            "Action" : [
                "codebuild:StartBuild", "codebuild:BatchGetBuilds",
                "iam:PassRole"
            ],
            "Effect":"Allow",
            "Resource":"*"
        },
        {
            "Action":[
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
                
            ],
            "Effect":"Allow",
            "Resource":"${aws_codecommit_repository.test.arn}"
    
        }
    ]
}
E0F
}

resource "aws_iam_role_policy_attachment" "codepipeline-attach" {
    role = aws_iam_role.codepipeline_role.name
    policy_arn = aws_iam_policy.codepipeline_policy.arn
  }

resource "aws_codepipeline" "pipeline" {
    name = "${var.source_repo_name}-${var.source_repo_branch}-Pipeline"
    role_arn = aws_iam_role.codepipeline_role.arn
    artifact_store {
      location = aws_s3_bucket.artifact_bucket.bucket
      type = "S3"
    }

    stage {
      name = "Source"
      action {
        name = "Source"
        category = "Source"
        owner = "AWS"
        version = "1"
        provider = "CodeCommit"
        output_artifacts = ["SourceOutput"]
        run_order = 1
        configuration = {
          RepositoryName = var.source_repo_name
          BranchName = var.source_repo_branch
          PollForSourceChanges = "true"
        }
      }
    }

    stage {
      name = "Build"
      action {
        name = "Build"
        category = "Build"
        owner = "AWS"
        version = "1"
        provider = "CodeBuild"
        input_artifacts = ["SourceOutput"]
        output_artifacts = ["BuildOutput"]
        run_order = 1
        configuration = {
          ProjectName = aws_codebuild_project.codebuild.id
        }


      }
    }  
    
}


resource "aws_iam_role" "trigger_role" {
  name = "terraform-trigger"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_policy" "trigger_policy" {
  description = "CodePipeline Trigger Execution Policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "codepipeline:StartPipelineExecution"
      ],
      "Effect": "Allow",
      "Resource": "${aws_codepipeline.pipeline.arn}"
    }
  ]
}
EOF
}
  
resource "aws_iam_role_policy_attachment" "trigger-attach" {
  role = aws_iam_role.trigger_role.name
  policy_arn = aws_iam_policy.trigger_policy.arn
  
}