resource "aws_cloudwatch_metric_alarm" "tickets-lambda_is_idle_for_2min" {
  alarm_name          = "lambda_is_idle_for_2min"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2" // determines how many periods must be evaluated
  datapoints_to_alarm = "2" // determines how many data points must breach threshold to fire alarm in time period evaluation_periods * period
  period              = "60" // must be equal to metric resolution of corresponding metric or more
  statistic           = "Sum"
  threshold           = "2"
  treat_missing_data  = "breaching"

  metric_name       = "Invocations"
  namespace         = "AWS/Lambda"
  alarm_description = "Lambda wasn't invocated for 2 min"
  alarm_actions     = [var.sns_topic_arn]

  dimensions = {
    FunctionName = aws_lambda_function.lambda.function_name
  }

}