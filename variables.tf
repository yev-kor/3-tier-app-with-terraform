variable "aws_region" {
  default = "us-west-2"
}

variable "ssh_access" {
  default = "0.0.0.0/0"
}

variable "key_name" {
  default = "keyclick"
}

variable "public_key_path" {
  default = "/home/ubuntu/.ssh/keyclick.pub"
}

variable "front_instance_type" {
  default = "t2.micro"
}

variable "back_instance_type" {
  default = "t2.micro"
}

variable "redis_instance_type" {
  default = "t2.micro"
}

###

variable "front_alb_tg_port" {
  default = 80
}

variable "front_alb_protocol" {
  default = "HTTP"
}

variable "front_healthy_threshold" {
  default = 2
}

variable "front_unhealthy_threshold" {
  default = 2
}

variable "front_alb_timeout" {
  default = 3
}

variable "front_alb_interval" {
  default = 30
}

variable "front_listener_port" {
  default = 80
}

variable "front_listener_protocol" {
  default = "HTTP"
}

###

variable "back_alb_tg_port" {
  default = 80

}

variable "back_alb_protocol" {
  default = "HTTP"
}

variable "back_healthy_threshold" {
  default = 2
}

variable "back_unhealthy_threshold" {
  default = 2
}

variable "back_alb_timeout" {
  default = 3
}

variable "back_alb_interval" {
  default = 30
}

variable "back_listener_port" {
  default = 80
}

variable "back_listener_protocol" {
  default = "HTTP"
}


