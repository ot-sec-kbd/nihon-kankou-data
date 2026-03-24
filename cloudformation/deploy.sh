#!/bin/bash

# デプロイスクリプト for S3 Static Website

set -e

# 引数チェック
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 <environment> [profile]"
    echo "  environment: STG or PROD"
    echo "  profile: AWS profile name (optional)"
    echo ""
    echo "Examples:"
    echo "  $0 STG"
    echo "  $0 STG myprofile"
    echo "  $0 PROD production-profile"
    exit 1
fi

ENVIRONMENT=$1
AWS_PROFILE_ARG=""

# AWS プロファイルが指定された場合
if [ "$#" -eq 2 ]; then
    AWS_PROFILE_ARG="--profile $2"
    echo "Using AWS Profile: $2"
fi

# 環境名の検証と小文字変換
if [ "$ENVIRONMENT" != "STG" ] && [ "$ENVIRONMENT" != "PROD" ]; then
    echo "Error: Environment must be STG or PROD"
    exit 1
fi

# 環境名を小文字に変換
ENVIRONMENT_LOWER=$(echo "$ENVIRONMENT" | tr '[:upper:]' '[:lower:]')

# 変数設定
STACK_NAME="${ENVIRONMENT_LOWER}-japan47go-nihon-kankou-data-stack"
BUCKET_NAME="${ENVIRONMENT_LOWER}-japan47go-nihon-kankou-data"
TEMPLATE_FILE="s3-static-website.yaml"
REGION="ap-northeast-1"

echo "=========================================="
echo "Deploying to Environment: $ENVIRONMENT"
echo "Stack Name: $STACK_NAME"
echo "Region: $REGION"
echo "=========================================="

# CloudFormationスタックのデプロイ
echo "Deploying CloudFormation stack..."
aws cloudformation deploy \
    --template-file $TEMPLATE_FILE \
    --stack-name $STACK_NAME \
    --parameter-overrides Environment=$ENVIRONMENT_LOWER \
    --region $REGION \
    --capabilities CAPABILITY_IAM \
    $AWS_PROFILE_ARG

# スタックの出力を取得
echo "Getting stack outputs..."
CLOUDFRONT_URL=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query "Stacks[0].Outputs[?OutputKey=='CloudFrontURL'].OutputValue" \
    --output text \
    $AWS_PROFILE_ARG)

CLOUDFRONT_ID=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query "Stacks[0].Outputs[?OutputKey=='CloudFrontDistributionId'].OutputValue" \
    --output text \
    $AWS_PROFILE_ARG)

echo "=========================================="
echo "Deployment Complete!"
echo "CloudFront URL: $CLOUDFRONT_URL"
echo "CloudFront Distribution ID: $CLOUDFRONT_ID"
echo "=========================================="