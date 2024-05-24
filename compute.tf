# EC2 AMI to use
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Create SSH keys (if required we could create different keys for front,back and redis apps)
resource "aws_key_pair" "click_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# redis instance

resource "aws_instance" "redis_node" {
  count         = 1
  instance_type = var.redis_instance_type
  ami           = data.aws_ami.ubuntu.id

  tags = {
    Name = "redis-node"
  }

  key_name = aws_key_pair.click_auth.id

  vpc_security_group_ids = [aws_security_group.redis_sg.id]
  subnet_id              = aws_subnet.redis_subnet[count.index].id
  user_data = templatefile("${path.root}/redisdata.tpl",
    {
      port = 6379
    }
  )
}

resource "aws_instance" "front_node" {
  count         = 1
  depends_on    = [aws_instance.back_node]
  instance_type = var.front_instance_type
  ami           = data.aws_ami.ubuntu.id

  tags = {
    Name = "front-node"
  }

  key_name = aws_key_pair.click_auth.id

  vpc_security_group_ids = [aws_security_group.front_asg_sg["front_asg"].id]
  subnet_id              = aws_subnet.front_app_subnet[count.index].id

  user_data = templatefile("${path.root}/frontdata.tpl",
    {
      private_ip_back = aws_instance.back_node[0].private_ip
    }
  )
}

resource "aws_instance" "back_node" {
  count         = 1
  depends_on    = [aws_instance.redis_node]
  instance_type = var.back_instance_type
  ami           = data.aws_ami.ubuntu.id

  tags = {
    Name = "back-node"
  }

  key_name = aws_key_pair.click_auth.id

  vpc_security_group_ids = [aws_security_group.back_asg_sg["back_asg"].id]
  subnet_id              = aws_subnet.back_app_subnet[count.index].id

  user_data = templatefile("${path.root}/backdata.tpl",
    {
      private_ip_redis = aws_instance.redis_node[0].private_ip
    }
  )
}

# # front app ASG EC2 Launch Template
# resource "aws_launch_template" "front_app_lt" {
#   name_prefix   = "front_app_template"
#   image_id      = data.aws_ami.ubuntu.id
#   instance_type = var.front_instance_type
#   key_name      = aws_key_pair.click_auth.id
#   network_interfaces {
#     device_index    = 0
#     security_groups = [aws_security_group.front_asg_sg["front_asg"].id]
#   }
#   # user_data =
#   tag_specifications {
#     resource_type = "instance"
#     tags = {
#       Name = "front-app-node"
#     }
#   }

#   tags = {
#     Name = "front app Launch Template"
#   }
# }

# # front app ASG
# resource "aws_autoscaling_group" "front_app_asg" {
#   desired_capacity    = 1
#   max_size            = 1
#   min_size            = 1
#   health_check_type   = "EC2"
#   target_group_arns   = [aws_lb_target_group.front_app_tg.arn]
#   vpc_zone_identifier = aws_subnet.front_app_subnet.*.id

#   launch_template {
#     id      = aws_launch_template.front_app_lt.id
#     version = "$Latest"
#   }
# }

# # back app ASG EC2 Launch Template
# resource "aws_launch_template" "back_app_lt" {
#   name_prefix   = "back_app_template"
#   image_id      = data.aws_ami.ubuntu.id
#   instance_type = var.back_instance_type
#   key_name      = aws_key_pair.click_auth.id
#   network_interfaces {
#     device_index    = 0
#     security_groups = [aws_security_group.back_asg_sg["back_asg"].id]
#   }
#   #user_data =

#   tag_specifications {
#     resource_type = "instance"
#     tags = {
#       Name = "back-app-node"
#     }
#   }

#   tags = {
#     Name = "back app Launch Template"
#   }
# }

# # back app ASG
# resource "aws_autoscaling_group" "back_app_asg" {
#   desired_capacity    = 1
#   max_size            = 1
#   min_size            = 1
#   health_check_type   = "EC2"
#   target_group_arns   = [aws_lb_target_group.back_app_tg.arn]
#   vpc_zone_identifier = aws_subnet.back_app_subnet.*.id

#   launch_template {
#     id      = aws_launch_template.back_app_lt.id
#     version = "$Latest"
#   }
# }