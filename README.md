### Creating AWS API Gateway + Lambda function with Terraforms

Simple IAC example of AWS Lambda function written on Python and available through API Gateway.
In addition to Lambda and API gateway, here we have:
1. two custom metrics based on metric filters for log groups
2. dashboard with these custom metrics and one metric created by metric math with these two metrics
3. alarms based on these three metrics

