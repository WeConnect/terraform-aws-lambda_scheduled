resource "aws_iam_role" "lambda" {
  count = "${var.enabled}"
  name  = "${var.lambda_name}"

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

resource "aws_iam_role_policy" "lambda" {
  count = "${var.enabled}"
  name  = "${var.lambda_name}"
  role  = "${aws_iam_role.lambda.name}"

  policy = "${var.iam_policy_document}"
}

resource "aws_lambda_function" "lambda" {
  count            = "${var.enabled}"
  runtime          = "${var.runtime}"
  filename         = "${var.lambda_zipfile}"
  function_name    = "${var.lambda_name}"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "${var.handler}"
  source_code_hash = "${var.source_code_hash}"
  timeout          = "${var.timeout}"
}

resource "aws_lambda_permission" "cloudwatch" {
  count         = "${var.enabled}"
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.lambda.arn}"
}

resource "aws_cloudwatch_event_rule" "lambda" {
  count               = "${var.enabled}"
  name                = "${var.lambda_name}"
  schedule_expression = "${var.schedule_expression}"
}

resource "aws_cloudwatch_event_target" "lambda" {
  count     = "${var.enabled}"
  target_id = "${var.lambda_name}"
  rule      = "${aws_cloudwatch_event_rule.lambda.name}"
  arn       = "${aws_lambda_function.lambda.arn}"
}
