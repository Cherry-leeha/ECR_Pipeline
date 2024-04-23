resource "aws_codecommit_repository" "test" {
    repository_name = var.source_repo_name   
    description = "This is the Sample App Repository"
}

output "source_repo_clone_url_http" {
    value = aws_codecommit_repository.test.clone_url_http
}