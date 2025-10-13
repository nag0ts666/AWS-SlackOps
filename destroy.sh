set -e
REGION="us-west-2"
ROLE_NAME="SlackOpsLambdaRole"
LAMBDA_NAME="SlackOpsAlertLambda"
RULE_NAME="EC2StopRule"

echo "[1/4] Removing EventBridge targets and rule..."
aws events remove-targets --rule $RULE_NAME --ids "1" --region $REGION || true
aws events delete-rule --name $RULE_NAME --region $REGION || true

echo "[2/4] Deleting Lambda function..."
aws lambda delete-function --function-name $LAMBDA_NAME --region $REGION || true

echo "[3/4] Detaching IAM policy..."
aws iam delete-role-policy --role-name $ROLE_NAME --policy-name SlackOpsPermissions --region $REGION || true

echo "[4/4] Deleting IAM role..."
aws iam delete-role --role-name $ROLE_NAME --region $REGION || true

echo "✅ Cleanup complete."
