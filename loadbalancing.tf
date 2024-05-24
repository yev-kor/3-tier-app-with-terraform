# front app ALB
resource "aws_lb" "front_alb" {
  name               = "front-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.front_alb_sg["front_alb"].id]
  subnets            = aws_subnet.front_app_subnet.*.id
  idle_timeout       = 400

  tags = {
    Name = "front-app-alb"
  }
}

# front app ALB target group
resource "aws_lb_target_group" "front_app_tg" {
  name     = "front-app-tg"
  port     = var.front_alb_tg_port
  protocol = var.front_alb_protocol
  vpc_id   = aws_vpc.click_vpc.id
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.front_healthy_threshold   #2
    unhealthy_threshold = var.front_unhealthy_threshold #2
    timeout             = var.front_alb_timeout         #3
    interval            = var.front_alb_interval        #30
  }

}

# front app ALB listener
resource "aws_lb_listener" "front_app_listener" {
  load_balancer_arn = aws_lb.front_alb.arn
  port              = var.front_listener_port     #80
  protocol          = var.front_listener_protocol #HTTP

  default_action {
    type = "forward"
    #target_group_arn = "arn:aws:elasticloadbalancing:us-west-2:058264248815:targetgroup/front-app-tg/8af269c181ac1a04"
    target_group_arn = aws_lb_target_group.front_app_tg.arn
  }
}

# # back app ALB
# resource "aws_lb" "back_alb" {
#   name               = "back-alb"
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.back_alb_sg["back_alb"].id]
#   subnets            = aws_subnet.back_app_subnet.*.id
#   idle_timeout       = 400

#   tags = {
#     Name = "back-app-alb"
#   }
# }

# # back app ALB target group
# resource "aws_lb_target_group" "back_app_tg" {
#   name     = "back-app-tg"
#   port     = var.back_alb_tg_port
#   protocol = var.back_alb_protocol
#   vpc_id   = aws_vpc.click_vpc.id
#   lifecycle {
#     ignore_changes        = [name]
#     create_before_destroy = true
#   }
#   health_check {
#     healthy_threshold   = var.back_healthy_threshold   #2
#     unhealthy_threshold = var.back_unhealthy_threshold #2
#     timeout             = var.back_alb_timeout         #3
#     interval            = var.back_alb_interval        #30
#   }

# }

# # back app ALB listener
# resource "aws_lb_listener" "back_app_listener" {
#   load_balancer_arn = aws_lb.back_alb.arn
#   port              = var.back_listener_port     #80
#   protocol          = var.back_listener_protocol #HTTP

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.back_app_tg.arn
#   }
# }


# Attach front app to Target group
resource "aws_lb_target_group_attachment" "front_tg_attach" {
  count            = 1
  target_group_arn = aws_lb_target_group.front_app_tg.arn
  #target_group_arn = "arn:aws:elasticloadbalancing:us-west-2:058264248815:targetgroup/front-app-tg/8af269c181ac1a04"
  target_id = aws_instance.front_node[count.index].id
  port      = 80
}