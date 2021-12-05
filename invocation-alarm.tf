resource "aws_cloudwatch_metric_alarm" "tickets-lambda_is_idle_for_2min" {
  alarm_name          = "lambda_is_idle_for_2min"
  comparison_operator = "LessThanThreshold"
  // datapoint is aggregated by condition from "statistic" value of corresponding metric
  // for period determined by "period"
  evaluation_periods  = "1" // determines how many periods must be evaluated
  datapoints_to_alarm = "1" // determines how many data points must breach threshold to fire alarm in time period evaluation_periods * period
  period              = "120" // must be equal or more of metric resolution of corresponding metric
  statistic           = "Sum" // determines condition to create datapoint from corresponding metric values at the end of period
  threshold           = "1"
  treat_missing_data  = "breaching"

  metric_name       = "Invocations"
  namespace         = "AWS/Lambda"
  alarm_description = "Lambda wasn't invocated for 2 min"
  alarm_actions     = [var.sns_topic_arn]

  dimensions = {
    FunctionName = aws_lambda_function.lambda.function_name
  }

}