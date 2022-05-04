variable "instance_type" {
  
}

resource "aws_instance" "default" {
  ami = "ami-0c3fd0f5d33134a76"

  vpc_security_group_ids = [ aws_security_group.default.id ]

  instance_type = var.instance_type

  user_data = file("http_server/user_data.sh")
}


// apacheにアクセスできるようにセキュリティグループを設定
resource "aws_security_group" "default" {
  name = "ec2"
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


# apply時にターミナルで値を確認したり、モジュールから値を取得する際に使える
output "public_dns" {
  value = aws_instance.default.public_dns
}
