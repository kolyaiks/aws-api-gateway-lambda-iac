resource "aws_cloudwatch_metric_alarm" "lambda_metric_alarm_start" {
  alarm_name          = "lambda_metric_alarm_start"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"

  // metric name
  metric_name = aws_cloudwatch_log_metric_filter.lambda_metric_filter_start.metric_transformation[0].name
  // metric namespace
  namespace   = aws_cloudwatch_log_metric_filter.lambda_metric_filter_start.metric_transformation[0].namespace

  period             = 60 //in seconds
  statistic          = "Sum"
  threshold          = "1"

  treat_missing_data = "notBreaching"
  alarm_description  = "This alarm triggers when metric ${aws_cloudwatch_log_metric_filter.lambda_metric_filter_start.metric_transformation[0].name} is above or eqals 1"
  alarm_actions      = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_metric_alarm_end" {
  alarm_name          = "lambda_metric_alarm_end"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"

  // metric name
  metric_name = aws_cloudwatch_log_metric_filter.lambda_metric_filter_end.metric_transformation[0].name
  // metric namespace
  namespace   = aws_cloudwatch_log_metric_filter.lambda_metric_filter_end.metric_transformation[0].namespace

  period             = 60 //in seconds
  statistic          = "Sum"
  threshold          = "1"
  treat_missing_data = "notBreaching"
  alarm_description  = "This alarm triggers when metric ${aws_cloudwatch_log_metric_filter.lambda_metric_filter_end.metric_transformation[0].name} is above or eqals 1"
  alarm_actions      = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_metric_alarm_percent_of_end" {
  alarm_name          = "lambda_metric_alarm_percent_of_end"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  //just trying to fire this alert
  threshold          = "40"
  alarm_description  = "This alarm triggers when percent of \"end\" in lambda logs is above 40%."
  insufficient_data_actions = []
  alarm_actions      = [var.sns_topic_arn]

  metric_query {
    id          = "e1"
    expression  = "m2/(m1+m2)*100"
    label       = "Percent of end"
    return_data = "true"
  }

  metric_query {
    id = "m2"

    metric {
      // metric name
      metric_name = aws_cloudwatch_log_metric_filter.lambda_metric_filter_end.metric_transformation[0].name
      // metric namespace
      namespace   = aws_cloudwatch_log_metric_filter.lambda_metric_filter_end.metric_transformation[0].namespace
      period      = "300"
      stat        = "Sum"
      }
    }

  metric_query {
    id = "m1"

    metric {
      // metric name
      metric_name = aws_cloudwatch_log_metric_filter.lambda_metric_filter_start.metric_transformation[0].name
      // metric namespace
      namespace   = aws_cloudwatch_log_metric_filter.lambda_metric_filter_start.metric_transformation[0].namespace
      period      = "300"
      stat        = "Sum"
    }
  }
}