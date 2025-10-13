set -e

REGION="us-west-2"
ROLE_NAME="SlackOpsLambdaRole"
LAMBDA_NAME="SlackOpsAlertLambda"
ZIP_FILE="lambda_function.zip"
SLACK_URL="YOUR_SLACK_WEBHOOK_URL_HERE"

echo "[1/6] Packaging Lambda..."
zip -r $ZIP_FILE lambda_function.py > /dev/null

echo "[2/6] Creating IAM role..."
aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file://trust-policy.json \
  --region $REGION || true

aws iam put-role-policy \
  --role-name $ROLE_NAME \
  --policy-name SlackOpsPermissions \
  --policy-document file://permissions-policy.json \
  --region $REGION

echo "[3/6] Deploying Lambda function..."
aws lambda create-function \
  --function-name $LAMBDA_NAME \
  --runtime python3.12 \
  --role arn:aws:iam::$(aws sts get-caller-identity --query "Account" --output text):role/$ROLE_NAME \
  --handler lambda_function.lambda_handler \
  --timeout 60 \
  --environment Variables="{SLACK_WEBHOOK_URL=$SLACK_URL}" \
  --zip-file fileb://$ZIP_FILE \
  --region $REGION || \
aws lambda update-function-code \
  --function-name $LAMBDA_NAME \
  --zip-file fileb://$ZIP_FILE \
  --region $REGION

echo "[4/6] Creating EventBridge rule..."
aws events put-rule \
  --name "EC2StopRule" \
  --event-pattern '{"source":["aws.ec2"],"detail-type":["EC2 Instance State-change Notification"],"detail":{"state":["stopped"]}}' \
  --state ENABLED \
  --description "Triggers Lambda when an EC2 instance stops" \
  --region $REGION

echo "[5/6] Linking Lambda as target..."
LAMBDA_ARN=$(aws lambda get-function \
  --function-name SlackOpsAlertLambda \
  --region $REGION \
  --query 'Configuration.FunctionArn' \
  --output text)

echo "Lambda ARN resolved: $LAMBDA_ARN"
aws events put-targets \
  --rule "EC2StopRule" \
  --targets "Id"="1","Arn"="$LAMBDA_ARN" \
  --region $REGION

echo "[6/6] Adding invoke permissions..."
aws lambda add-permission \
  --function-name $LAMBDA_NAME \
  --statement-id AllowExecutionFromEventBridge \
  --action 'lambda:InvokeFunction' \
  --principal events.amazonaws.com \
  --source-arn "$(aws events describe-rule --name EC2StopRule --query 'Arn' --output text)" \
  --region $REGION || true

echo "✅ Deployment complete. Lambda connected to EventBridge."
