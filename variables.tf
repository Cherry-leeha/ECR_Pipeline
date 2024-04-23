variable "aws_region" {
    description = "The AWS resion"
    default = "ap-northeast-1"
}

variable "source_repo_name" {
    description = "Source repo name"
    type = string
}

variable "image_repo_name" {
    description = "Image repo name"
    type = string
}

variable "container_name" {
    description = "Container Name"
    default = "my-container"
  
}

variable "source_repo_branch" {
    description = "Source repo branch"
    type = string
}