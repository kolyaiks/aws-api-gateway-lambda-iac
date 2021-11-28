locals {
  metric_namespace = aws_cloudwatch_log_metric_filter.lambda_metric_filter_start.metric_transformation[0].namespace
  metric_name_start      = aws_cloudwatch_log_metric_filter.lambda_metric_filter_start.metric_transformation[0].name
  metric_name_end     = aws_cloudwatch_log_metric_filter.lambda_metric_filter_end.metric_transformation[0].name
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "my-dashboard"

  //https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/CloudWatch-Dashboard-Body-Structure.html
  //https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/CloudWatch-Dashboard-Body-Structure.html#CloudWatch-Dashboard-Properties-Metrics-Array-Format
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          ["${local.metric_namespace}", "${local.metric_name_start}",{"id":"m1"}],
          ["${local.metric_namespace}", "${local.metric_name_end}",{"id":"m2"}],
          [{ "expression" : "m2/(m1+m2)*100", "label":"percent of end to all", "id": "e3"}]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "us-east-1",
        "title": "Dashboard for lambda metrics",
        "view": "singleValue"
      }
    }
  ]
}
EOF
}