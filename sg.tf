# SG for SSH
resource "aws_security_group" "ssh_sg" {
  name        = "ssh_sg"
  description = "SSH Security Group"
  vpc_id      = aws_vpc.click_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_access]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH Security Group"
  }
}

# SG for front app ALB
resource "aws_security_group" "front_alb_sg" {
  for_each    = local.front_alb_sg
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.click_vpc.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "front app ALB SG"
  }
}

# SG for front app ASG
resource "aws_security_group" "front_asg_sg" {
  for_each    = local.front_asg_sg
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.click_vpc.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port = ingress.value.from
      to_port   = ingress.value.to
      protocol  = ingress.value.protocol
      #security_groups = ingress.value.security_groups
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "front app ASG SG"
  }
}

# SG for back app ALB
resource "aws_security_group" "back_alb_sg" {
  for_each    = local.back_alb_sg
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.click_vpc.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "back app ALB SG"
  }
}

# SG for back app ASG
resource "aws_security_group" "back_asg_sg" {
  for_each    = local.back_asg_sg
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.click_vpc.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port = ingress.value.from
      to_port   = ingress.value.to
      protocol  = ingress.value.protocol
      #security_groups = ingress.value.security_groups
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "back app ASG SG"
  }
}

# SG for redis
resource "aws_security_group" "redis_sg" {
  name        = "redis_sg"
  description = "redis SG"
  vpc_id      = aws_vpc.click_vpc.id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    #security_groups = [aws_security_group.back_asg_sg["back_asg"].id]
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis SG"
  }
}