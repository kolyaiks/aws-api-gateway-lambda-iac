resource "aws_cloudwatch_log_metric_filter" "lambda_metric_filter" {
  log_group_name = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  name           = "lambda_metric_filter"
  pattern        = "START"
  metric_transformation {
    name          = "lambda_metric_start"
    namespace     = "logsNamespaceForLambda"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_metric_alarm" {
  alarm_name          = "lambda_metric_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"

  // metric name
  metric_name         = aws_cloudwatch_log_metric_filter.lambda_metric_filter.metric_transformation[0].name
  // metric namespace
  namespace           = aws_cloudwatch_log_metric_filter.lambda_metric_filter.metric_transformation[0].namespace

  period              = 60 //in seconds
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"
  alarm_description   = "This alarm triggers when metric ${aws_cloudwatch_log_metric_filter.lambda_metric_filter.metric_transformation[0].name} is above or eqals 1"
  alarm_actions       = [var.sns_topic_arn]
}