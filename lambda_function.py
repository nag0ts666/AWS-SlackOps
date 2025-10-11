import json
import os
import time
import urllib.request
import urllib.error
import boto3
from botocore.exceptions import ClientError

EC2 = boto3.client("ec2")
REGION = os.getenv("AWS_REGION", "us-west-2")
SLACK_WEBHOOK_URL = os.getenv("SLACK_WEBHOOK_URL")
DEFAULT_INSTANCE_ID = os.getenv("INSTANCE_ID")

def post_to_slack(message: str):
    if not SLACK_WEBHOOK_URL:
        print("[WARN] SLACK_WEBHOOK_URL not set. Skipping Slack notification.")
        return
    data = json.dumps({"text": message}).encode("utf-8")
    req = urllib.request.Request(
        SLACK_WEBHOOK_URL,
        data=data,
        headers={"Content-Type": "application/json"}
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            print(f"[INFO] Slack response: {resp.status}")
    except urllib.error.URLError as e:
        print(f"[ERROR] Failed to post to Slack: {e}")

def restart_instance(instance_id: str):
    try:
        print(f"[INFO] Attempting to start instance {instance_id}")
        EC2.start_instances(InstanceIds=[instance_id])
        waiter = EC2.get_waiter("instance_running")
        waiter.wait(InstanceIds=[instance_id], WaiterConfig={"Delay": 10, "MaxAttempts": 30})
        print(f"[INFO] Instance {instance_id} is running.")
        return True
    except ClientError as e:
        print(f"[ERROR] Could not start instance {instance_id}: {e}")
        return False

def extract_instance_id(event):
    try:
        return event.get("detail", {}).get("instance-id") or DEFAULT_INSTANCE_ID
    except Exception:
        return DEFAULT_INSTANCE_ID

def lambda_handler(event, context):
    print("[DEBUG] Received event:", json.dumps(event))
    instance_id = extract_instance_id(event)
    if not instance_id:
        msg = "No instance ID found in event and INSTANCE_ID not set."
        print("[ERROR]", msg)
        post_to_slack(f"⚠️ SlackOps: {msg}")
        return {"statusCode": 400, "body": msg}

    restarted = restart_instance(instance_id)
    ts = time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime())
    if restarted:
        msg = f"✅ SlackOps: Auto-remediated EC2 instance *{instance_id}* at {ts} UTC (state=running)."
    else:
        msg = f"❌ SlackOps: Failed to start EC2 instance *{instance_id}* at {ts} UTC."
    post_to_slack(msg)
    return {"statusCode": 200 if restarted else 500, "body": msg}
