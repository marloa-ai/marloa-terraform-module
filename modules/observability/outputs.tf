output "sns_topic_arn" {
  description = "Alarm SNS topic ARN."
  value       = aws_sns_topic.alarms.arn
}
