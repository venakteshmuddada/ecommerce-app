provider "aws" {
  region = var.region
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name   = "ecommerce-ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Launch Template
resource "aws_launch_template" "app_template" {
  name_prefix   = "ecommerce-template"
  image_id      = "ami-0c94855ba95c71c99"
  instance_type = var.instance_type
  key_name      = "jenkins"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  user_data = base64encode(file("scripts/userdata.sh"))
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ecommerce-app"
    propagate_at_launch = true
  }
}

# RDS MySQL
resource "aws_db_instance" "mysql" {
  allocated_storage     = 20
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"
  username              = var.db_username
  password              = var.db_password
  skip_final_snapshot   = true
  publicly_accessible   = true
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  db_subnet_group_name  = aws_db_subnet_group.db_subnet.name
}

# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet" {
  name       = "ecommerce-db-subnet"
  subnet_ids = var.subnet_ids
}

# Random ID for bucket naming
resource "random_id" "bucket_id" {
  byte_length = 4
}

# S3 Bucket for CodePipeline artifacts
resource "aws_s3_bucket" "pipeline_bucket" {
  bucket        = "ecommerce-pipeline-artifacts-${random_id.bucket_id.hex}"
  force_destroy = true
}

# CodeBuild Project
resource "aws_codebuild_project" "ecommerce_build" {
  name          = "ecommerce-build"
  description   = "Build project for ecommerce"
  build_timeout = 5
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "NODE_ENV"
      value = "production"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

# CodeDeploy (application + group)
resource "aws_codedeploy_app" "ecommerce_app" {
  name             = "ecommerce-codedeploy-app"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "ecommerce_deploy_group" {
  app_name              = aws_codedeploy_app.ecommerce_app.name
  deployment_group_name = "ecommerce-deploy-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "ecommerce-app"
    }
  }

  deployment_style {
    deployment_type   = "IN_PLACE"
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

# CodePipeline
resource "aws_codepipeline" "ecommerce_pipeline" {
  name     = "ecommerce-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "venakteshmuddada"
        Repo       = "ecommerce-app"
        Branch     = "main"
        OAuthToken = "ghp_fd4ac03f4417cd45ab6751400a324763a7be0c60"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildAction"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.ecommerce_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployAction"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.ecommerce_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.ecommerce_deploy_group.deployment_group_name
      }
    }
  }
}
