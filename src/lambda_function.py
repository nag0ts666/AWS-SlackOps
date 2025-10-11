import json, os, boto3, urllib3
from datetime import datetime

http = urllib3.PoolManager()
ec2 = boto3.client('ec2')
WEBHOOK_URL = os.environ['SLACK_WEBHOOK_URL']

def lambda_handler(event, context):
    detail = event.get('detail', {})
    instance_id = detail.get('instance-id')
    state = detail.get('state')

    msg = f":rotating_light: *AWS Alert!* Instance `{instance_id}` is `{state}`"
    if state == 'stopped':
        try:
            ec2.start_instances(InstanceIds=[instance_id])
            msg = f":white_check_mark: *Remediation:* `{instance_id}` restarted automatically"
        except Exception as e:
            msg = f":x: *Remediation failed:* {str(e)}"

    http.request("POST", WEBHOOK_URL,
        body=json.dumps({"text": msg}),
        headers={"Content-Type": "application/json"}
    )
    return {"status": "ok"}
