# AWS Budget Configuration
provider "aws" {  
  region = "us-east-1"
}

resource "aws_budgets_budget" "operator_guardrail" {  
  name              = "TKH-Phase2-Budget"  
  budget_type       = "COST"  
  limit_amount      = "75"  
  limit_unit        = "USD"  
  time_unit         = "MONTHLY"  

  # SABOTAGE 1: Syntax error (missing required 'notification_type')  
  notification {    
    comparison_operator        = "GREATER_THAN"    
    threshold                  = 50    
    threshold_type             = "PERCENTAGE"    
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["omrikaf94@gmail.com"]  
  }
}