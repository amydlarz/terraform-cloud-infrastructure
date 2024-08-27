output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "load_balancer_arn" {
  value = aws_lb.public.arn
}
