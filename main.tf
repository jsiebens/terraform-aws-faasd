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

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  // Terraform removes the default rule
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

resource "aws_instance" "faasd" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
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
