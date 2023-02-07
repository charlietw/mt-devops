resource "aws_ecr_repository" "mt-ecr" {
  name                 = "mt-devops"
}

resource "aws_ecs_cluster" "mt-ecs" {
  name = "mt-ecs"
}

resource "aws_ecs_cluster_capacity_providers" "mt-capacity" {
  cluster_name = aws_ecs_cluster.mt-ecs.name
  capacity_providers = ["FARGATE"]
}

resource "aws_iam_role" "ecr-role" {
  name = "ecr-role"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    ]


  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}



resource "aws_ecs_task_definition" "mt" {
  family                   = "mt-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecr-role.arn
  task_role_arn = "arn:aws:iam::261219435789:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  runtime_platform {
    operating_system_family = "LINUX"
  }
  container_definitions = jsonencode([
    {
      name      = "mt-task"
      image     = "${aws_ecr_repository.mt-ecr.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
        logConfiguration = {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "firelens-container",
                "awslogs-region": "eu-west-2",
                "awslogs-create-group": "true",
                "awslogs-stream-prefix": "firelens"
            }
        }
    }
    ]
  ) 
}


resource "aws_ecs_service" "dt_devops" {
  name            = "mt-devops"
  task_definition = aws_ecs_task_definition.mt.arn
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.mt-ecs.id
  desired_count   = 1
  network_configuration {
    assign_public_ip = true
    security_groups = [
      aws_security_group.mt.id
    ]
    subnets = module.vpc.public_subnets
  }
}

resource "aws_security_group" "mt" {
  name        = "charlie_ip"
  description = "Allow traffic from my IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "My IP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}