resource "random_id" "id" {
  byte_length = 8
}

data "aws_elb_service_account" "main" {}

# -----------------------------------------------------------------------------------------
# VPC Configuration
# -----------------------------------------------------------------------------------------
module "vpc1" {
  source                  = "./modules/vpc"
  vpc_name                = "vpc1"
  vpc_cidr                = "10.1.0.0/16"
  azs                     = var.azs
  public_subnets          = var.vpc1_public_subnets
  private_subnets         = var.vpc1_private_subnets
  enable_dns_hostnames    = true
  enable_dns_support      = true
  create_igw              = true
  map_public_ip_on_launch = true
  enable_nat_gateway      = true
  single_nat_gateway      = false
  one_nat_gateway_per_az  = true
  tags = {
    Name = "vpc1"
  }
}

module "vpc2" {
  source                  = "./modules/vpc"
  vpc_name                = "vpc2"
  vpc_cidr                = "10.2.0.0/16"
  azs                     = var.azs
  public_subnets          = var.vpc2_public_subnets
  private_subnets         = var.vpc2_private_subnets
  enable_dns_hostnames    = true
  enable_dns_support      = true
  create_igw              = true
  map_public_ip_on_launch = true
  enable_nat_gateway      = true
  single_nat_gateway      = false
  one_nat_gateway_per_az  = true
  tags = {
    Name = "vpc2"
  }
}

module "vpc3" {
  source                  = "./modules/vpc"
  vpc_name                = "vpc3"
  vpc_cidr                = "10.3.0.0/16"
  azs                     = var.azs
  public_subnets          = var.vpc3_public_subnets
  private_subnets         = var.vpc3_private_subnets
  enable_dns_hostnames    = true
  enable_dns_support      = true
  create_igw              = true
  map_public_ip_on_launch = true
  enable_nat_gateway      = true
  single_nat_gateway      = false
  one_nat_gateway_per_az  = true
  tags = {
    Name = "vpc3"
  }
}

module "vpc4" {
  source                  = "./modules/vpc"
  vpc_name                = "vpc4"
  vpc_cidr                = "10.4.0.0/16"
  azs                     = var.azs
  public_subnets          = var.vpc4_public_subnets
  private_subnets         = var.vpc4_private_subnets
  enable_dns_hostnames    = true
  enable_dns_support      = true
  create_igw              = true
  map_public_ip_on_launch = true
  enable_nat_gateway      = true
  single_nat_gateway      = false
  one_nat_gateway_per_az  = true
  tags = {
    Name = "vpc4"
    # EKS requires these tags on the VPC and subnets to discover them
    "kubernetes.io/cluster/eks-cluster" = "shared"
  }
}


module "lattice_sg_vpc1" {
  source = "./modules/security-groups"
  name   = "lattice-sg-vpc1"
  vpc_id = module.vpc1.vpc_id
  ingress_rules = [
    {
      description     = "VPC Lattice link-local"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = []
      cidr_blocks     = ["169.254.170.0/23"]
    }
  ]
  egress_rules = [
    {
      description     = "Allow all outbound"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = { Name = "lattice-sg-vpc1" }
}

module "lattice_sg_vpc2" {
  source = "./modules/security-groups"
  name   = "lattice-sg-vpc2"
  vpc_id = module.vpc2.vpc_id
  ingress_rules = [
    {
      description     = "VPC Lattice link-local"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = []
      cidr_blocks     = ["169.254.170.0/23"]
    }
  ]
  egress_rules = [
    {
      description     = "Allow all outbound"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = { Name = "lattice-sg-vpc2" }
}

module "lattice_sg_vpc3" {
  source = "./modules/security-groups"
  name   = "lattice-sg-vpc3"
  vpc_id = module.vpc3.vpc_id
  ingress_rules = [
    {
      description     = "VPC Lattice link-local"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = []
      cidr_blocks     = ["169.254.170.0/23"]
    }
  ]
  egress_rules = [
    {
      description     = "Allow all outbound"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = { Name = "lattice-sg-vpc3" }
}

module "lattice_sg_vpc4" {
  source = "./modules/security-groups"
  name   = "lattice-sg-vpc4"
  vpc_id = module.vpc4.vpc_id
  ingress_rules = [
    {
      description     = "VPC Lattice link-local HTTPS"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = []
      cidr_blocks     = ["169.254.170.0/23"]
    },
    {
      description     = "VPC Lattice link-local HTTP"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = []
      cidr_blocks     = ["169.254.170.0/23"]
    }
  ]
  egress_rules = [
    {
      description     = "Allow all outbound"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = { Name = "lattice-sg-vpc4" }
}

module "ecs_lb_sg" {
  source = "./modules/security-groups"
  name   = "ecs-lb-sg"
  vpc_id = module.vpc1.vpc_id
  ingress_rules = [
    {
      description     = "HTTP Traffic"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = []
      cidr_blocks     = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      description     = "Allow outbound traffic to al"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = {
    Name = "ecs-lb-sg"
  }
}

module "ecs_sg" {
  source = "./modules/security-groups"
  name   = "ecs-sg"
  vpc_id = module.vpc1.vpc_id
  ingress_rules = [
    {
      description     = "ECS Traffic"
      from_port       = 8080
      to_port         = 8080
      protocol        = "tcp"
      security_groups = [module.ecs_lb_sg.id]
      cidr_blocks     = []
    }
  ]
  egress_rules = [
    {
      description     = "Allow outbound traffic to al"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = {
    Name = "ecs-sg"
  }
}

module "lambda_sg" {
  source        = "./modules/security-groups"
  name          = "lambda-sg"
  vpc_id        = module.vpc2.vpc_id
  ingress_rules = []
  egress_rules = [
    {
      description     = "Allow outbound traffic to al"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = {
    Name = "lambda-sg"
  }
}

module "ec2_lb_sg" {
  source = "./modules/security-groups"
  name   = "ec2-lb-sg"
  vpc_id = module.vpc3.vpc_id
  ingress_rules = [
    {
      description     = "HTTP Traffic"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = []
      cidr_blocks     = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      description     = "Allow outbound traffic to al"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = {
    Name = "ec2-lb-sg"
  }
}

module "ec2_asg_sg" {
  source = "./modules/security-groups"
  name   = "ec2-asg-sg"
  vpc_id = module.vpc3.vpc_id
  ingress_rules = [
    {
      description     = "HTTP Traffic"
      from_port       = 8080
      to_port         = 8080
      protocol        = "tcp"
      security_groups = [module.ec2_lb_sg.id]
      cidr_blocks     = []
    }
  ]
  egress_rules = [
    {
      description     = "Allow outbound traffic to al"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = {
    Name = "ec2-asg-sg"
  }
}

# -----------------------------------------------------------------------------------------
# ECS Configuration
# -----------------------------------------------------------------------------------------
module "container_registry" {
  source               = "./modules/ecr"
  force_delete         = true
  scan_on_push         = false
  image_tag_mutability = "IMMUTABLE"
  bash_command         = "bash ${path.cwd}/../src/ecr-build-push.sh nodeapp ${var.region}"
  name                 = "nodeapp"
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

module "ecs_task_execution_role" {
  source             = "./modules/iam"
  role_name          = "ecs-task-execution-role"
  role_description   = "IAM role for ECS task execution"
  policy_name        = "ecs-task-execution-policy"
  policy_description = "IAM policy for ECS task execution"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                  "Service": "ecs-tasks.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
  policy             = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                  "s3:PutObject",
                  "ecr:GetAuthorizationToken",
                  "ecr:BatchCheckLayerAvailability",
                  "ecr:GetDownloadUrlForLayer",
                  "ecr:BatchGetImage",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
                ],
                "Resource": "*",
                "Effect": "Allow"
            }
        ]
    }
    EOF
}

module "ecs_lb_logs_bucket" {
  source      = "./modules/s3"
  bucket_name = "ecs-lb-logs-bucket-${var.region}"
  objects     = []
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::ecs-lb-logs-bucket-${var.region}/*"
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::ecs-lb-logs-bucket-${var.region}"
      },
      {
        Sid    = "AWSELBAccountWrite"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::ecs-lb-logs-bucket-${var.region}/*"
      }
    ]
  })
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    },
    {
      allowed_headers = ["*"]
      allowed_methods = ["PUT"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  versioning_enabled = "Enabled"
  force_destroy      = true
}

module "nodeapp_ecs_log_group" {
  source            = "./modules/cloudwatch/cloudwatch-log-group"
  log_group_name    = "/aws/ecs/nodeapp-ecs-log-group"
  skip_destroy      = false
  retention_in_days = 90
}

module "ecs_lb" {
  source                     = "terraform-aws-modules/alb/aws"
  name                       = "ecs-lb"
  load_balancer_type         = "application"
  vpc_id                     = module.vpc1.vpc_id
  subnets                    = module.vpc1.private_subnets
  enable_deletion_protection = false
  drop_invalid_header_fields = true
  ip_address_type            = "ipv4"
  internal                   = true
  security_groups = [
    module.ecs_lb_sg.id
  ]
  access_logs = {
    bucket = "${module.ecs_lb_logs_bucket.bucket}"
  }
  listeners = {
    ecs_lb_http_listener = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "ecs_target_group"
      }
    }
  }
  target_groups = {
    ecs_target_group = {
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "ip"
      vpc_id           = module.vpc1.vpc_id
      health_check = {
        enabled             = true
        healthy_threshold   = 3
        interval            = 30
        path                = "/"
        port                = 8080
        protocol            = "HTTP"
        unhealthy_threshold = 3
      }
      create_attachment = false
    }
  }
}

module "ecs_cluster" {
  source       = "terraform-aws-modules/ecs/aws"
  cluster_name = "ecs-cluster"
  services = {
    nodeapp_ecs = {
      cpu                    = 2048
      memory                 = 4096
      task_exec_iam_role_arn = module.ecs_task_execution_role.arn
      iam_role_arn           = module.ecs_task_execution_role.arn
      desired_count          = 2
      assign_public_ip       = false
      deployment_controller = {
        type = "ECS"
      }
      network_mode = "awsvpc"
      runtime_platform = {
        cpu_architecture        = "X86_64"
        operating_system_family = "LINUX"
      }
      launch_type              = "FARGATE"
      scheduling_strategy      = "REPLICA"
      requires_compatibilities = ["FARGATE"]
      container_definitions = {
        nodeapp_ecs = {
          cpu       = 1024
          memory    = 2048
          essential = true
          image     = "${module.container_registry.repository_url}:latest"
          ulimits = [
            {
              name      = "nofile"
              softLimit = 65536
              hardLimit = 65536
            }
          ]
          portMappings = [
            {
              name          = "nodeapp_ecs"
              containerPort = 8080
              hostPort      = 8080
              protocol      = "tcp"
            }
          ]
          environment            = []
          readonlyRootFilesystem = false
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = module.nodeapp_ecs_log_group.name
              awslogs-region        = var.region
              awslogs-stream-prefix = "nodeapp-ecs"
            }
          }
          memoryReservation = 100
          restartPolicy = {
            enabled              = true
            ignoredExitCodes     = [1]
            restartAttemptPeriod = 60
          }
        }
      }
      load_balancer = {
        service = {
          target_group_arn = module.ecs_lb.target_groups["ecs_target_group"].arn
          container_name   = "nodeapp_ecs"
          container_port   = 8080
        }
      }
      subnet_ids                    = module.vpc1.private_subnets
      vpc_id                        = module.vpc1.vpc_id
      security_group_ids            = [module.ecs_sg.id]
      availability_zone_rebalancing = "ENABLED"
    }
  }
}

# -----------------------------------------------------------------------------------------
# Lambda Configuration
# -----------------------------------------------------------------------------------------
module "lambda_function_code" {
  source      = "./modules/s3"
  bucket_name = "lambda-function-code-${random_id.id.hex}"
  objects = [
    {
      key    = "lambda.zip"
      source = "./files/lambda.zip"
    }
  ]
  bucket_policy = ""
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  versioning_enabled = "Enabled"
  force_destroy      = true
}

module "lambda_function_iam_role" {
  source             = "./modules/iam"
  role_name          = "lambda-function-iam-role"
  role_description   = "IAM role for lambda function"
  policy_name        = "lambda-function-iam-policy"
  policy_description = "IAM policy lambda function"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                  "Service": "lambda.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
  policy             = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
                ],
                "Resource": "arn:aws:logs:*:*:*",
                "Effect": "Allow"
            },
            {
              "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface"
              ],
              "Effect"   : "Allow",
              "Resource" : "*"
            }
        ]
    }
    EOF
}

module "lambda_function" {
  source        = "./modules/lambda"
  function_name = "lambda-function"
  role_arn      = module.lambda_function_iam_role.arn
  vpc_config = {
    security_group_ids = [module.lambda_sg.id]
    subnet_ids         = module.vpc2.private_subnets
  }
  env_variables           = {}
  handler                 = "lambda.lambda_handler"
  runtime                 = "python3.12"
  s3_bucket               = module.lambda_function_code.bucket
  s3_key                  = "lambda.zip"
  layers                  = []
  code_signing_config_arn = null
  tags = {
    Name = "lambda-function"
  }
}

resource "aws_lambda_permission" "allow_lattice" {
  statement_id  = "AllowVPCLatticeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.arn
  principal     = "vpc-lattice.amazonaws.com"
  source_arn    = module.service2_target_group.target_group_arn
}

# -----------------------------------------------------------------------------------------
# EC2 Configuration
# -----------------------------------------------------------------------------------------
module "ec2_lb_logs_bucket" {
  source      = "./modules/s3"
  bucket_name = "ec2-lb-logs-bucket-${var.region}"
  objects     = []
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::ec2-lb-logs-bucket-${var.region}/*"
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::ec2-lb-logs-bucket-${var.region}"
      },
      {
        Sid    = "AWSELBAccountWrite"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::ec2-lb-logs-bucket-${var.region}/*"
      }
    ]
  })
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    },
    {
      allowed_headers = ["*"]
      allowed_methods = ["PUT"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  versioning_enabled = "Enabled"
  force_destroy      = true
}

module "nodeapp_ec2_log_group" {
  source            = "./modules/cloudwatch/cloudwatch-log-group"
  log_group_name    = "/aws/ec2/nodeapp-ec2-log-group"
  skip_destroy      = false
  retention_in_days = 90
}

module "ec2_lb" {
  source                     = "terraform-aws-modules/alb/aws"
  name                       = "ec2-lb"
  load_balancer_type         = "application"
  vpc_id                     = module.vpc3.vpc_id
  subnets                    = module.vpc3.private_subnets
  enable_deletion_protection = false
  drop_invalid_header_fields = true
  ip_address_type            = "ipv4"
  internal                   = true
  security_groups = [
    module.ec2_lb_sg.id
  ]
  access_logs = {
    bucket = "${module.ec2_lb_logs_bucket.bucket}"
  }
  listeners = {
    ec2_lb_http_listener = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "ec2_target_group"
      }
    }
  }
  target_groups = {
    ec2_target_group = {
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "instance"
      vpc_id           = module.vpc3.vpc_id
      health_check = {
        enabled             = true
        healthy_threshold   = 3
        interval            = 30
        path                = "/"
        port                = 8080
        protocol            = "HTTP"
        unhealthy_threshold = 3
      }
      create_attachment = false
    }
  }
}

module "iam_instance_profile_role" {
  source             = "./modules/iam"
  role_name          = "iam-instance-profile-role"
  role_description   = "Instance Profile Role for EC2 Instances"
  policy_name        = "iam-instance-profile-policy"
  policy_description = "IAM policy for EC2 instance profile"
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
  policy             = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                  "s3:*"
                ],
                "Resource": "*",
                "Effect": "Allow"
            }
        ]
    }
    EOF
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "iam-instance-profile"
  role = module.iam_instance_profile_role.name
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "launch_template" {
  source                               = "./modules/launch_template"
  name                                 = "launch-template"
  description                          = "launch-template"
  ebs_optimized                        = false
  image_id                             = data.aws_ami.ubuntu.id
  instance_type                        = "t2.micro"
  instance_initiated_shutdown_behavior = "stop"
  instance_profile_name                = aws_iam_instance_profile.iam_instance_profile.name
  key_name                             = "madmaxkeypair"
  network_interfaces = [
    {
      associate_public_ip_address = false
      security_groups             = [module.ec2_asg_sg.id]
    }
  ]
  user_data = base64encode(templatefile("${path.module}/scripts/user_data.sh", {}))
}

module "asg" {
  source                    = "./modules/auto_scaling_group"
  name                      = "asg"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  target_group_arns         = [module.ec2_lb.target_groups["ec2_target_group"].arn]
  vpc_zone_identifier       = module.vpc3.private_subnets
  launch_template_id        = module.launch_template.id
  launch_template_version   = "$Latest"
}

# Create VPC Lattice Service Network
# resource "aws_vpclattice_service_network" "lattice_network" {
#   name      = "lattice-network"
#   auth_type = "AWS_IAM"
#   tags = {
#     Name = "lattice-network"
#   }
# }

# # Associate VPCs to the service network
# resource "aws_vpclattice_service_network_vpc_association" "vpc1_assoc" {
#   service_network_identifier = aws_vpclattice_service_network.lattice_network.id
#   vpc_identifier             = module.vpc1.vpc_id
#   security_group_ids         = [module.lattice_sg.id]
# }

# resource "aws_vpclattice_service_network_vpc_association" "vpc2_assoc" {
#   service_network_identifier = aws_vpclattice_service_network.lattice_network.id
#   vpc_identifier             = module.vpc2.vpc_id
#   security_group_ids         = [module.lattice_sg.id]
# }

# resource "aws_vpclattice_service_network_vpc_association" "vpc3_assoc" {
#   service_network_identifier = aws_vpclattice_service_network.lattice_network.id
#   vpc_identifier             = module.vpc3.vpc_id
#   security_group_ids         = [module.lattice_sg.id]
# }

# # Create target groups for services
# resource "aws_vpclattice_target_group" "service1_tg" {
#   name = "service1-target-group"
#   type = "ALB"

#   config {
#     port           = 80
#     protocol       = "HTTP"
#     vpc_identifier = module.vpc1.vpc_id
#   }
# }

# resource "aws_vpclattice_target_group" "service2_tg" {
#   name = "service2-target-group"
#   type = "LAMBDA"
# }

# resource "aws_vpclattice_target_group" "service3_tg" {
#   name = "service3-target-group"
#   type = "ALB"

#   config {
#     port           = 80
#     protocol       = "HTTP"
#     vpc_identifier = module.vpc3.vpc_id
#   }
# }

# resource "aws_vpclattice_target_group_attachment" "service1_attach" {
#   target_group_identifier = aws_vpclattice_target_group.service1_tg.id
#   target {
#     id   = module.ecs_lb.id
#     port = 80
#   }
# }

# resource "aws_vpclattice_target_group_attachment" "service2_attach" {
#   target_group_identifier = aws_vpclattice_target_group.service2_tg.id
#   target {
#     id = module.lambda_function.id
#   }
# }

# resource "aws_vpclattice_target_group_attachment" "service3_attach" {
#   target_group_identifier = aws_vpclattice_target_group.service3_tg.id
#   target {
#     id   = module.ec2_lb.id
#     port = 80
#   }
# }

# # Create Lattice Services
# resource "aws_vpclattice_service" "service1" {
#   name            = "service1"
#   auth_type       = "AWS_IAM"
#   certificate_arn = null
# }

# resource "aws_vpclattice_listener" "service1_listener" {
#   service_identifier = aws_vpclattice_service.service1.id
#   name               = "http-listener"
#   port               = 80
#   protocol           = "HTTP"

#   default_action {
#     forward {
#       target_groups {
#         target_group_identifier = aws_vpclattice_target_group.service1_tg.id
#         weight                  = 100
#       }
#     }
#   }
# }

# resource "aws_vpclattice_service" "service2" {
#   name            = "service2"
#   auth_type       = "AWS_IAM"
#   certificate_arn = null
# }

# resource "aws_vpclattice_listener" "service2_listener" {
#   service_identifier = aws_vpclattice_service.service2.id
#   name               = "http-listener"
#   port               = 80
#   protocol           = "HTTP"

#   default_action {
#     forward {
#       target_groups {
#         target_group_identifier = aws_vpclattice_target_group.service2_tg.id
#         weight                  = 100
#       }
#     }
#   }
# }

# resource "aws_vpclattice_service" "service3" {
#   name            = "service3"
#   auth_type       = "AWS_IAM"
#   certificate_arn = null
# }

# resource "aws_vpclattice_listener" "service3_listener" {
#   service_identifier = aws_vpclattice_service.service3.id
#   name               = "http-listener"
#   port               = 80
#   protocol           = "HTTP"

#   default_action {
#     forward {
#       target_groups {
#         target_group_identifier = aws_vpclattice_target_group.service3_tg.id
#         weight                  = 100
#       }
#     }
#   }
# }

# # Associate services to the service network
# resource "aws_vpclattice_service_network_service_association" "service1_assoc" {
#   service_identifier         = aws_vpclattice_service.service1.id
#   service_network_identifier = aws_vpclattice_service_network.lattice_network.id
# }

# resource "aws_vpclattice_service_network_service_association" "service2_assoc" {
#   service_identifier         = aws_vpclattice_service.service2.id
#   service_network_identifier = aws_vpclattice_service_network.lattice_network.id
# }

# resource "aws_vpclattice_service_network_service_association" "service3_assoc" {
#   service_identifier         = aws_vpclattice_service.service3.id
#   service_network_identifier = aws_vpclattice_service_network.lattice_network.id
# }


# Service Network Module
module "lattice_service_network" {
  source = "./modules/lattice/service-network"

  name      = "lattice-network"
  auth_type = "AWS_IAM"

  vpc_associations = {
    vpc1 = {
      vpc_id             = module.vpc1.vpc_id
      security_group_ids = [module.lattice_sg_vpc1.id]
    }
    vpc2 = {
      vpc_id             = module.vpc2.vpc_id
      security_group_ids = [module.lattice_sg_vpc2.id]
    }
    vpc3 = {
      vpc_id             = module.vpc3.vpc_id
      security_group_ids = [module.lattice_sg_vpc3.id]
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# Target Group Modules
module "service1_target_group" {
  source = "./modules/lattice/target-group"

  name = "service1-target-group"
  type = "ALB"

  config = {
    port           = 80
    protocol       = "HTTP"
    vpc_identifier = module.vpc1.vpc_id
  }

  targets = {
    ecs_lb = {
      id   = module.ecs_lb.arn
      port = 80
    }
  }

  tags = {
    Service     = "service1"
    Environment = "production"
  }
}

module "service2_target_group" {
  source = "./modules/lattice/target-group"

  name = "service2-target-group"
  type = "LAMBDA"

  targets = {
    lambda_function = {
      id = module.lambda_function.arn
    }
  }

  tags = {
    Service     = "service2"
    Environment = "production"
  }
}

module "service3_target_group" {
  source = "./modules/lattice/target-group"

  name = "service3-target-group"
  type = "ALB"

  config = {
    port           = 80
    protocol       = "HTTP"
    vpc_identifier = module.vpc3.vpc_id
  }

  targets = {
    ec2_lb = {
      id   = module.ec2_lb.arn
      port = 80
    }
  }

  tags = {
    Service     = "service3"
    Environment = "production"
  }
}

# Lattice Service Modules
module "lattice_service1" {
  source = "./modules/lattice/lattice"

  name      = "service1"
  auth_type = "AWS_IAM"

  listeners = {
    http = {
      name     = "http-listener"
      port     = 80
      protocol = "HTTP"
      forward = {
        target_groups = [
          {
            target_group_identifier = module.service1_target_group.target_group_id
            weight                  = 100
          }
        ]
      }
    }
  }

  service_network_associations = {
    main = {
      service_network_id = module.lattice_service_network.service_network_id
    }
  }

  tags = {
    Service     = "service1"
    Environment = "production"
  }
}

module "lattice_service2" {
  source = "./modules/lattice/lattice"

  name      = "service2"
  auth_type = "AWS_IAM"

  listeners = {
    http = {
      name     = "http-listener"
      port     = 80
      protocol = "HTTP"
      forward = {
        target_groups = [
          {
            target_group_identifier = module.service2_target_group.target_group_id
            weight                  = 100
          }
        ]
      }
    }
  }

  service_network_associations = {
    main = {
      service_network_id = module.lattice_service_network.service_network_id
    }
  }

  tags = {
    Service     = "service2"
    Environment = "production"
  }
}

module "lattice_service3" {
  source = "./modules/lattice/lattice"

  name      = "service3"
  auth_type = "AWS_IAM"

  listeners = {
    http = {
      name     = "http-listener"
      port     = 80
      protocol = "HTTP"
      forward = {
        target_groups = [
          {
            target_group_identifier = module.service3_target_group.target_group_id
            weight                  = 100
          }
        ]
      }
    }
  }

  service_network_associations = {
    main = {
      service_network_id = module.lattice_service_network.service_network_id
    }
  }

  tags = {
    Service     = "service3"
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------------------
# EKS node SG — nodes need to reach Lattice link-local range
# -----------------------------------------------------------------------------------------
module "eks_node_sg" {
  source = "./modules/security-groups"
  name   = "eks-node-sg"
  vpc_id = module.vpc4.vpc_id
  ingress_rules = [
    {
      # nodes talking to each other (required by EKS)
      description     = "Node to node all traffic"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      security_groups = []
      cidr_blocks     = ["10.4.0.0/16"]
    }
  ]
  egress_rules = [
    {
      description     = "Allow all outbound includes Lattice 169.254.170.0/23"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = { Name = "eks-node-sg" }
}

# -----------------------------------------------------------------------------------------
# Associate vpc4 to the existing Lattice service network
# -----------------------------------------------------------------------------------------
resource "aws_vpclattice_service_network_vpc_association" "vpc4_assoc" {
  service_network_identifier = module.lattice_service_network.service_network_id
  vpc_identifier             = module.vpc4.vpc_id
  security_group_ids         = [module.lattice_sg_vpc4.id]
}

# -----------------------------------------------------------------------------------------
# IAM — EKS cluster role
# -----------------------------------------------------------------------------------------
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })

  tags = { Name = "eks-cluster-role" }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# -----------------------------------------------------------------------------------------
# IAM — EKS node group role
# -----------------------------------------------------------------------------------------
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = { Name = "eks-node-role" }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_readonly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_ssm" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Inline policy: allow pods on nodes to call Lattice services via SigV4
resource "aws_iam_role_policy" "eks_node_lattice" {
  name = "eks-node-lattice-invoke"
  role = aws_iam_role.eks_node_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLatticeServiceInvoke"
        Effect = "Allow"
        Action = [
          "vpc-lattice-svcs:Invoke"
        ]
        # Scope to exactly your three Lattice services
        Resource = [
          module.lattice_service1.service_arn,
          module.lattice_service2.service_arn,
          module.lattice_service3.service_arn,
        ]
      }
    ]
  })
}

# -----------------------------------------------------------------------------------------
# EKS Cluster
# -----------------------------------------------------------------------------------------
resource "aws_eks_cluster" "eks" {
  name     = "eks-cluster"
  version  = var.eks_cluster_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = concat(module.vpc4.private_subnets, module.vpc4.public_subnets)
    security_group_ids      = [module.eks_node_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true # set false once you have a bastion/VPN
  }

  # Ship control plane logs to CloudWatch
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]

  tags = { Name = "eks-cluster" }
}

resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/eks-cluster/cluster"
  retention_in_days = 90
}

# -----------------------------------------------------------------------------------------
# EKS Managed Node Group
# -----------------------------------------------------------------------------------------
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  # Nodes go into private subnets only
  subnet_ids = module.vpc4.private_subnets

  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 5
  }

  update_config {
    max_unavailable = 1
  }

  # Label nodes so workloads can select them
  labels = {
    role = "lattice-client"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_readonly,
  ]

  tags = { Name = "eks-node-group" }
}

# -----------------------------------------------------------------------------------------
# EKS add-ons
# -----------------------------------------------------------------------------------------
resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "coredns"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.eks_nodes]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_update = "OVERWRITE"
}

# -----------------------------------------------------------------------------------------
# Lattice auth policy — allow EKS node role to invoke all three services
# Applied at service network level so it covers all associated services
# -----------------------------------------------------------------------------------------
resource "aws_vpclattice_auth_policy" "eks_to_services" {
  resource_identifier = module.lattice_service_network.service_network_arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEKSNodes"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.eks_node_role.arn
        }
        Action   = "vpc-lattice-svcs:Invoke"
        Resource = "*"
      }
    ]
  })
}