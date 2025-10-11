# 🚀 AWS SlackOps — Serverless Alerting & Auto-Remediation System

A fully automated **serverless incident-response pipeline** built on AWS.  
It detects EC2 instance stoppage events via **Amazon EventBridge**, triggers a **Lambda** function for **auto-remediation**, and sends real-time alerts to a **Slack channel**.

---

## 🧩 Architecture Diagram

```mermaid
graph TD
    A[EC2 Instance (SlackOpsTest)] -->|State change: stopped| B[Amazon EventBridge Rule (EC2StopRule)]
    B -->|Invokes| C[AWS Lambda Function (SlackOpsAlertLambda)]
    C -->|Restarts EC2 & Sends Alert| D[Slack Channel (#aws-alerts-1)]
