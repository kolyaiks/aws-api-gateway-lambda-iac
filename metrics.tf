resource "aws_cloudwatch_log_metric_filter" "lambda_metric_filter_start" {
  log_group_name = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  name           = "lambda_metric_filter_start"
  pattern        = "START"

  //creating metric from the metric filter
  metric_transformation {
    name          = "lambda_metric_start"
    namespace     = "logsNamespaceForLambda"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "lambda_metric_filter_end" {
  log_group_name = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  name           = "lambda_metric_filter_end"
  pattern        = "END"

  metric_transformation {
    name          = "lambda_metric_end"
    namespace     = "logsNamespaceForLambda"
    value         = "1"
    default_value = "0"
  }
}

