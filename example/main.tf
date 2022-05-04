// provider:cloud APIの明示
provider "aws" {
  region = "ap-northeast-1"
}

# terraform実行時に`-var opniton`か`環境変数(TF_VAR_<name>)`によって上書き可能
# 上書きがない場合にdefaultが使用される
variable "example_instance_type" {
  default = "t3.micro"
}

# # ローカル変数は上書きができない
# locals {
#   example_instance_type = "t3.micro"
# }

# データソースを使うと外部データを参照できる
# data "aws_ami" "example" {
#   most_recent = true

#   owners = ["amazon"]
#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-0.????????-x82_64-gp2"]
#   }
# }



// apacheにアクセスできるようにセキュリティグループを設定
resource "aws_security_group" "example_ec2" {
  name = "example-ec2"
  ingress {
    from_port   = 80
    to_port     = 80
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


resource "aws_instance" "example" {
  ami                    = "ami-0c3fd0f5d33134a76"
  instance_type          = var.example_instance_type
  vpc_security_group_ids = [aws_security_group.example_ec2.id]

  user_data = <<EOF
    #!/bin/bash
    yum install -y httpd
    systemctl start httpd.service
    EOF
}

# apply時にターミナルで値を確認したり、モジュールから値を取得する際に使える
output "example_public_dns" {
  value = aws_instance.example.public_dns
}

