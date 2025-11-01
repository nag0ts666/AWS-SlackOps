![AWS](https://img.shields.io/badge/AWS-Lambda-orange?logo=amazon-aws)
![Slack](https://img.shields.io/badge/Slack-Integration-blue?logo=slack)
![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![EventBridge](https://img.shields.io/badge/EventBridge-Triggered-purple)
![Serverless](https://img.shields.io/badge/Serverless-Automation-success)

# AWS SlackOps — Serverless Alerting & Auto-Remediation System

A fully automated **serverless incident-response pipeline** built on AWS.  
It detects EC2 instance stoppage events via **Amazon EventBridge**, triggers a **Lambda** function for **auto-remediation**, and sends real-time alerts to a **Slack channel**.

---

## Architecture Diagram

```mermaid
graph TD
    A["EC2 Instance (SlackOpsTest)"] -->|State change: stopped| B["Amazon EventBridge Rule (EC2StopRule)"]
    B -->|Invokes| C["AWS Lambda Function (SlackOpsAlertLambda)"]
    C -->|Restarts EC2 & Sends Alert| D["Slack Channel (#aws-alerts-1)"]
```

---

## Tech Stack

| Component               | Purpose                                          |
| ----------------------- | ------------------------------------------------ |
| **AWS Lambda**          | Executes remediation logic & Slack notifications |
| **Amazon EventBridge**  | Detects EC2 stop events                          |
| **Slack Webhook**       | Receives real-time alerts                        |
| **IAM Role**            | Grants Lambda logging & EC2 permissions          |
| **Python 3.12 + Boto3** | Implements logic using AWS SDK                   |

---

## Workflow Summary

1️⃣ **EC2 instance stops** — triggers a state change.  
2️⃣ **EventBridge** detects the `stopped` state and matches it against the rule.  
3️⃣ **EventBridge** invokes the **Lambda** function.  
4️⃣ **Lambda** restarts the EC2 instance and posts a Slack alert to `#aws-alerts-1`.  

---

## Testing the Pipeline

### Manual Invocation (via AWS CLI)
You can manually invoke the Lambda function using a sample event payload to validate both remediation and Slack alert delivery:

``bash
aws lambda invoke \
  --region us-west-2 \
  --function-name SlackOpsAlertLambda \
  --payload fileb://test-event.json \
  response.json


**Status:** Functional  
**Region:** us-west-2  
**Webhook Verified:** :white_check_mark: SlackOps test message delivered successfully  
**Lambda → EventBridge Integration:** Established and confirmed  

---

## Project Demonstration — AWS SlackOps (Automated Incident Response)

This section showcases the end-to-end automation workflow connecting **AWS EC2**, **EventBridge**, **Lambda**, and **Slack**.

| Screenshot | Description |
|-------------|--------------|
| ![Lambda Function](screenshots/01-lambda-function-dashboard.png) | **Lambda Function – SlackOpsAlertLambda**<br>Configured to trigger on EC2 stop events and forward alerts to Slack. |
| ![IAM Role](screenshots/02-iam-role-policy.png) | **IAM Role – SlackOpsLambdaRole**<br>Grants Lambda permissions for EC2 and CloudWatch access. |
| ![EventBridge Rule](screenshots/03-eventbridge-rule-cli-proof.png) | **EventBridge Rule**<br>CLI output confirming the rule *EC2StopRule* listening for EC2 “stopped” events. |
| ![CloudWatch Logs](screenshots/04-cloudwatch-log-stream.png) | **CloudWatch Logs**<br>Execution logs verifying Lambda was triggered and Slack message sent successfully. |
| ![Slack Alert](screenshots/05-slack-alert-message.png) | **Slack Alert Channel – #aws-slackops**<br>Received real-time notification: “:rotating_light: EC2 instance stopped – Auto-remediation triggered.” |
| ![Architecture](screenshots/06-architecture-diagram.png) | **Architecture Overview**<br>EC2 → EventBridge → Lambda → Slack Webhook pipeline for automated incident alerts. |

---

| Badge | Description |
|-------|--------------|
| ![AWS Lambda](https://img.shields.io/badge/AWS-Lambda-orange?logo=awslambda) | Core execution logic |
| ![EventBridge](https://img.shields.io/badge/AWS-EventBridge-blueviolet?logo=amazoneventbridge) | Detects EC2 stop events |
| ![Slack API](https://img.shields.io/badge/Slack-Webhook-4A154B?logo=slack) | Sends real-time alerts |
| ![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python) | Lambda runtime |
| ![Status](https://img.shields.io/badge/Status-Active-success?style=flat) | Current project state |
