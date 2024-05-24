locals {
  vpc_cidr = "10.123.0.0/16"
}

# Defining Subnet CIDR Range for front app Subnets to only have even numbers
locals {
  front_subnet_cidr = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
}

# Defining Subnet CIDR Range for back app Subnets to only have odd numbers
locals {
  back_subnet_cidr = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
}

# Defining Subnet CIDR Range for redis Subnets to only have odd numbers
locals {
  redis_subnet_cidr = [for i in range(5, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
}

# AZs to use
locals {
  azs = data.aws_availability_zones.available.names
}

### front app and back app SG ingress rules
locals {
  front_alb_sg = {
    front_alb = {
      name        = "front_alb_sg"
      description = "front app ALB SG"
      ingress = {
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
  front_asg_sg = {
    front_asg = {
      name        = "front_asg_sg"
      description = "front app ASG SG"
      ingress = {
        http = {
          from     = 80
          to       = 80
          protocol = "tcp"
          #security_groups = [aws_security_group.front_alb_sg["front_alb"].id]
          cidr_blocks = ["0.0.0.0/0"]
        }
        https = {
          from     = 443
          to       = 443
          protocol = "tcp"
          #security_groups = [aws_security_group.front_alb_sg["front_alb"].id]
          cidr_blocks = ["0.0.0.0/0"]
        }
        ssh = {
          from     = 22
          to       = 22
          protocol = "tcp"
          #security_groups = [aws_security_group.ssh_sg.id]
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
  back_alb_sg = {
    back_alb = {
      name        = "back_alb_sg"
      description = "back app ALB SG"
      ingress = {
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
  back_asg_sg = {
    back_asg = {
      name        = "back_asg_sg"
      description = "back app ASG SG"
      ingress = {
        http = {
          from     = 80
          to       = 80
          protocol = "tcp"
          #security_groups = [aws_security_group.back_alb_sg["back_alb"].id]
          cidr_blocks = ["0.0.0.0/0"]
        }
        https = {
          from     = 443
          to       = 443
          protocol = "tcp"
          #security_groups = [aws_security_group.back_alb_sg["back_alb"].id]
          cidr_blocks = ["0.0.0.0/0"]
        }
        ssh = {
          from     = 22
          to       = 22
          protocol = "tcp"
          #security_groups = [aws_security_group.ssh_sg.id]
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}