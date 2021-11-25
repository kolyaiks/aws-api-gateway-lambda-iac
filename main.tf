provider "aws" {
  region = "us-east-1"
}

data "archive_file" "lambda-zip" {
  output_path = "lambda.zip"
  type        = "zip"
  source_dir  = "lambda"
}

resource "aws_iam_role" "lambda-iam" {
  name               = "lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "allow_write_to_cloud_watch" {
  policy = jsonencode(
  {
    Version : "2012-10-17",
    Statement : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ], Resource : [
        "*"
      ]
      }
    ]
  })
  role   = aws_iam_role.lambda-iam.id
}

resource "aws_lambda_function" "lambda" {
  filename         = "lambda.zip"
  function_name    = "lambda-function"
  role             = aws_iam_role.lambda-iam.arn
  handler          = "lambda.lambda_handler"
  source_code_hash = data.archive_file.lambda-zip.output_base64sha256
  runtime          = "python3.8"
}

resource "aws_apigatewayv2_api" "lambda-api-gw" {
  name          = "lambda-api-gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda-stage" {
  name        = "$default"
  auto_deploy = true
  api_id      = aws_apigatewayv2_api.lambda-api-gw.id
}

resource "aws_apigatewayv2_integration" "intergation-bw-lambda-and-api-gw" {
  api_id               = aws_apigatewayv2_api.lambda-api-gw.id
  integration_type     = "AWS_PROXY"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.lambda.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.intergation-bw-lambda-and-api-gw.id}"
  api_id    = aws_apigatewayv2_api.lambda-api-gw.id
}

resource "aws_lambda_permission" "api-gw" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "apigateway.amazonaws.com"
  statement_id  = "AllowExecutionFromAPIGateway"
  source_arn    = "${aws_apigatewayv2_api.lambda-api-gw.execution_arn}/*/*/*"
}