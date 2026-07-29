provider "aws" {
  region = "us-east-1"
}

# ====================================================================
# TITAN FINTECH: THE MONITORED FORTRESS
# Build your VPC, Subnets, Flow Logs, Security Group, and EC2 instance below.
# 
# Hint: When your EC2 instance needs an IAM profile, use:
# iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
# 
# Hint: When your Flow Log needs an IAM role, use:
# iam_role_arn = aws_iam_role.flow_log_role.arn
# ====================================================================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
# ======== PERIMETER ======== #

resource "aws_vpc" "titan" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "titan-prod-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.titan.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  # No public IP = no outbound path to the SSM service
  map_public_ip_on_launch = true

  tags = {
    Name = "titan-public-subnet"
  }
}


resource "aws_internet_gateway" "titan" {
  vpc_id = aws_vpc.titan.id

  tags = {
    Name = "titan-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.titan.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.titan.id
  }

  tags = {
    Name = "titan-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ======== WIRETAP ======== #

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/tkh/titan-prod-vpc-logs"
  retention_in_days = 1
}

resource "aws_flow_log" "titan" {
  vpc_id               = aws_vpc.titan.id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn         = aws_iam_role.flow_log_role.arn

  tags = {
    Name = "titan-flow-log"
  }
}

# ======== ZERO TRUST COMPUTE ======== #

resource "aws_security_group" "zero_trust" {
  name        = "titan-zero-trust-sg"
  description = "Zero ingress. Outbound only - admin access via SSM Session Manager."
  vpc_id      = aws_vpc.titan.id

  egress {
    description = "Allow all outbound (SSM agent dials out to AWS endpoints)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "titan-zero-trust-sg"
  }
}

resource "aws_instance" "titan" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro" # no t2
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.zero_trust.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "titan-prod-host"
  }
}

# ======== OUTPUTS ======== #

output "instance_id" {
  description = "Use with: aws ssm start-session --target <instance_id>"
  value       = aws_instance.titan.id
}

output "flow_log_group" {
  value = aws_cloudwatch_log_group.vpc_flow_logs.name
}
