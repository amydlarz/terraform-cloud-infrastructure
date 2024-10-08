resource "aws_ecs_cluster" "main" {
  name = "nginx-cluster"
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.access_to_bucket_role_arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:latest"
      cpu       = 256
      memory    = 512
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_lb_target_group" "nginx" {
  name        = "nginx-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = var.load_balancer_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
}

resource "aws_ecs_service" "nginx" {
  name            = "nginx-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx.arn
    container_name   = "nginx"
    container_port   = 80
  }

  tags = {
    Name = "nginx-service"
  }
}

resource "aws_security_group" "ecs" {
  name        = "ecs-sg"
  description = "Allow traffic from ALB"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = var.allow_traffic_from_sgs
  }

  tags = {
    Name = "ecs-sg"
  }
}

resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.id}/${aws_ecs_service.nginx.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling Policy for Scaling Out
resource "aws_appautoscaling_policy" "scale_out" {
  name                   = "scale-out"
  policy_type            = "StepScaling"
  resource_id            = aws_appautoscaling_target.ecs.id
  scalable_dimension     = "ecs:service:DesiredCount"
  service_namespace      = "ecs"
  step_scaling_policy_configuration {
    adjustment_type = "ChangeInCapacity"
    cooldown        = 60
    step_adjustment {
      scaling_adjustment = 1
      metric_interval_lower_bound = "0"
    }
  }
}

# Auto Scaling Policy for Scaling In
resource "aws_appautoscaling_policy" "scale_in" {
  name                   = "scale-in"
  policy_type            = "StepScaling"
  resource_id            = aws_appautoscaling_target.ecs.id
  scalable_dimension     = "ecs:service:DesiredCount"
  service_namespace      = "ecs"
  step_scaling_policy_configuration {
    adjustment_type = "ChangeInCapacity"
    cooldown        = 60
    step_adjustment {
      scaling_adjustment = -1
      metric_interval_upper_bound = "0"
    }
  }
}
