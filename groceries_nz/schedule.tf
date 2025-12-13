resource "aws_cloudwatch_event_rule" "daily_schedule_rule" {
  name                = "daily-sfn-trigger"
  description         = "每日 UTC 時間 18:00(NZ 07:00) 觸發 Step Function"
  schedule_expression = "cron(0 18 * * ? *)" 

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_cloudwatch_event_target" "sfn_target" {
  rule      = aws_cloudwatch_event_rule.daily_schedule_rule.name
  target_id = "StepFunctionTarget"
  arn       = aws_sfn_state_machine.fetch_rank_stores_ingestion.arn
  role_arn  = aws_iam_role.eventbridge_sfn_invocation_role.arn
}
