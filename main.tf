locals {
  generate_password   = var.basic_auth_password == null || var.basic_auth_password == ""
  basic_auth_user     = var.basic_auth_user
  basic_auth_password = local.generate_password ? random_password.faasd[0].result : var.basic_auth_password

  user_data_vars = {
    basic_auth_user     = local.basic_auth_user
    basic_auth_password = local.basic_auth_password
    domain              = var.domain
    email               = var.email
  }
}

resource "random_password" "faasd" {
  count   = local.generate_password ? 1 : 0
  length  = 16
  special = false
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "faasd" {
  name        = var.name
  description = "Allow all incoming traffic"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = toset(var.domain == "" ? [8080] : [80, 443])
    content {
      cidr_blocks = [
        "0.0.0.0/0"
      ]
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_iam_role" "faasd" {
  name               = var.name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "faasd" {
  name = var.name
  role = aws_iam_role.faasd.id
}

resource "aws_iam_policy_attachment" "faasd" {
  name       = format("%s-attachment", var.name)
  roles      = [aws_iam_role.faasd.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_instance" "faasd" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.faasd.id
  user_data_base64       = base64encode(templatefile("${path.module}/templates/startup.sh", local.user_data_vars))
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.faasd.id]
  subnet_id              = var.subnet_id

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_eip" "faasd" {
  vpc = true

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_eip_association" "faasd" {
  instance_id   = aws_instance.faasd.id
  allocation_id = aws_eip.faasd.id
}
