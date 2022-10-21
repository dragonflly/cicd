#######################################################
# ASG Launch Template
#######################################################
resource "aws_launch_template" "jenkins_launch_template" {
  name = "jenkins-launch-template"
  description = "Jenkins Launch template"
  image_id = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type

  vpc_security_group_ids = [ module.jenkins_sg.security_group_id ]
  key_name = var.instance_keypair
  user_data = filebase64("${path.module}/bash-files/userdata-jenkins.sh")
  ebs_optimized = true
  update_default_version = true
  iam_instance_profile {
    name = aws_iam_instance_profile.jenkins_profile.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 10         
      delete_on_termination = true
      volume_type = "gp2" # default is gp2 
    }
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = local.common_tags
  }
}

resource "aws_launch_template" "sonarqube_launch_template" {
  name = "sonarqube-launch-template"
  description = "sonarqube Launch template"
  image_id = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [ module.sonarqube_sg.security_group_id ]
  key_name = var.instance_keypair
  user_data = filebase64("${path.module}/bash-files/userdata-sonarqube.sh")
  ebs_optimized = true
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 10         
      delete_on_termination = true
      volume_type = "gp2" # default is gp2 
    }
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = local.common_tags
  }
}
#######################################################
# ASG
#######################################################
resource "aws_autoscaling_group" "jenkins" {
  name_prefix = "jenks-asg-"
  desired_capacity = 1
  max_size = 1
  min_size = 1
 
  vpc_zone_identifier = module.vpc.private_subnets
  target_group_arns = [module.alb.target_group_arns[0]]
  health_check_type = "ELB"

  # default health_check_grace_period = 300
  launch_template {
    id = aws_launch_template.jenkins_launch_template.id 
    version = aws_launch_template.jenkins_launch_template.latest_version
  }

  # Instance Refresh
  instance_refresh {
    strategy = "Rolling"
    preferences {
      # instance_warmup = 300 
      # Default behavior is to use the Auto Scaling Groups health check grace period value
      min_healthy_percentage = 50            
    }
    triggers = [ "desired_capacity" ]
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-jenkins"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "sonarqube" {
  name_prefix = "sonar-asg-"
  desired_capacity = 1
  max_size = 1
  min_size = 1
 
  vpc_zone_identifier = module.vpc.private_subnets
  target_group_arns = [module.alb.target_group_arns[1]]
  health_check_type = "ELB"

  # default health_check_grace_period = 300
  launch_template {
    id = aws_launch_template.sonarqube_launch_template.id 
    version = aws_launch_template.sonarqube_launch_template.latest_version
  }

  # Instance Refresh
  instance_refresh {
    strategy = "Rolling"
    preferences {
      # instance_warmup = 300 
      # Default behavior is to use the Auto Scaling Groups health check grace period value
      min_healthy_percentage = 50            
    }
    triggers = [ "desired_capacity" ]
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-sonarqube"
    propagate_at_launch = true
  }
}


#######################################################
# SNS
#######################################################
# SNS - Topic
# AWS Bug for SNS Topic: https://stackoverflow.com/questions/62694223/cloudwatch-alarm-pending-confirmation
# Due to that create SNS Topic with unique name 
resource "aws_sns_topic" "myasg_sns_topic" {
  name = "myasg-sns-topic-${random_pet.this.id}"
  tags = local.common_tags
}

# SNS - Subscription
resource "aws_sns_topic_subscription" "myasg_sns_topic_subscription" {
  topic_arn = aws_sns_topic.myasg_sns_topic.arn
  protocol  = "email"
  endpoint  = "ning.hanning@gmail.com"
}

# Create Notification Resource
resource "aws_autoscaling_notification" "myasg_notifications" {
  group_names = [aws_autoscaling_group.jenkins.id]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn = aws_sns_topic.myasg_sns_topic.arn 
}

# Create Random Pet Resource
resource "random_pet" "this" {
  length = 2
}


#######################################################
# Target Tracking Scaling Policies
#######################################################
# Scaling Policy-1: Based on CPU Utilization
resource "aws_autoscaling_policy" "avg_cpu_policy_greater_than_xx" {
  name                   = "avg-cpu-policy-greater-than-xx"
  # "SimpleScaling" "StepScaling" "TargetTrackingScaling". Default is "SimpleScaling"
  policy_type = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.jenkins.id
  # ASG default cooldown 300 seconds 
  estimated_instance_warmup = 180

  # CPU Utilization is above 50%
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

# Scaling Policy-2: Based on ALB Target Requests
resource "aws_autoscaling_policy" "alb_target_requests_greater_than_yy" {
  name                   = "alb-target-requests-greater-than-yy"
  # "SimpleScaling" "StepScaling" "TargetTrackingScaling". Default is "SimpleScaling"
  policy_type = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.jenkins.id 
  # ASG default cooldown 300 seconds 
  estimated_instance_warmup = 120 

  # Number of requests > 10 completed per target
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label =  "${module.alb.lb_arn_suffix}/${module.alb.target_group_arn_suffixes[0]}"    
    }
    target_value = 10.0
  }    
}


#######################################################
# Scheduled Actions
#######################################################
# Scheduled Action-1: Increase capacity during business hours
resource "aws_autoscaling_schedule" "increase_capacity_7am" {
  scheduled_action_name  = "increase-capacity-7am"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 8
  start_time             = "2030-03-30T11:00:00Z" # UTC Timezone
  recurrence             = "00 09 * * *"
  autoscaling_group_name = aws_autoscaling_group.jenkins.id 
}

# Scheduled Action-2: Decrease capacity during business hours
resource "aws_autoscaling_schedule" "decrease_capacity_5pm" {
  scheduled_action_name  = "decrease-capacity-5pm"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 2
  start_time             = "2030-03-30T21:00:00Z" # UTC Timezone
  recurrence             = "00 21 * * *"
  autoscaling_group_name = aws_autoscaling_group.jenkins.id
}


#######################################################
# IAM Role for ASG EC2
#######################################################
resource "aws_iam_role" "jenkins_role" {
  name = "${local.name}-jenkins-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.jenkins_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.jenkins_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AdministratorAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.jenkins_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.jenkins_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AWSKeyManagementServicePowerUser" {
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
  role       = aws_iam_role.jenkins_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AWSLambdaRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
  role       = aws_iam_role.jenkins_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AWSCloudFormationFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
  role       = aws_iam_role.jenkins_role.name
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins_profile"
  role = aws_iam_role.jenkins_role.name
}
