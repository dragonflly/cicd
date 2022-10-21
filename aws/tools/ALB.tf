#######################################################
# ALB module
#######################################################
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "6.0.0"

  name = "${local.name}-alb"
  load_balancer_type = "application"
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  security_groups = [module.loadbalancer_sg.security_group_id]

  # HTTP Listener 80 - HTTP to HTTPS Redirect, no rules
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
    {
      port               = 9000
      protocol           = "HTTP"
      action_type        = "forward"
      target_group_index = 1
    }
  ]

  # HTTPS Listener 443
  https_listeners = [
    # https_listener_index = 0
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      action_type = "fixed-response"
      # default rule
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed Static message - for Root Context"
        status_code  = "200"
      }
    }, 
  ]

  # HTTPS Listener Rules
  https_listener_rules = [
    { 
      https_listener_index = 0
      priority = 1
      actions = [
        {
          type               = "forward"
          target_group_index = 0
        }
      ]
      conditions = [{
        path_patterns = ["/*"]
      }]
    }
  ]

  target_groups = [
    # target_group_index = 0
    {
      name_prefix          = "jenks-"
      backend_protocol     = "HTTP"
      backend_port         = 8080
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/login"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }

      protocol_version = "HTTP1"
      tags =local.common_tags # Target Group Tags
    },
    {
      name_prefix          = "sonar-"
      backend_protocol     = "HTTP"
      backend_port         = 9000
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/login"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }

      protocol_version = "HTTP1"
      tags =local.common_tags # Target Group Tags
    }
  ]

  tags = local.common_tags # ALB Tags
}


#######################################################
# Route53 host zone, record, SSL for ALB
#######################################################
# SSL Certificates for ALB
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "3.0.0"

  domain_name  = trimsuffix(data.aws_route53_zone.mydomain.name, ".")
  zone_id      = data.aws_route53_zone.mydomain.zone_id 

  subject_alternative_names = [
    "*.ning-cicd.click"
  ]
  tags = local.common_tags
}

# Public host zone record for ALB
resource "aws_route53_record" "jenkins_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id 
  name    = "jenkins.ning-cicd.click"
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

# Domain name of Route53 host zone
data "aws_route53_zone" "mydomain" {
  name         = "ning-cicd.click"
}
