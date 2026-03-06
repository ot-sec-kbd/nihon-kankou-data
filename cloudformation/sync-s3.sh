#!/bin/bash

# S3へのコンテンツ同期スクリプト

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
BUCKET_NAME="${ENVIRONMENT_LOWER}-japan47go-nihon-kankou-data"
STACK_NAME="${ENVIRONMENT_LOWER}-japan47go-nihon-kankou-data-stack"
REGION="ap-northeast-1"
SOURCE_DIR="../"

echo "=========================================="
echo "Syncing to S3 Bucket: $BUCKET_NAME"
echo "Environment: $ENVIRONMENT"
echo "=========================================="

# CloudFront Distribution IDを取得
CLOUDFRONT_ID=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query "Stacks[0].Outputs[?OutputKey=='CloudFrontDistributionId'].OutputValue" \
    --output text \
    $AWS_PROFILE_ARG 2>/dev/null)

if [ -z "$CLOUDFRONT_ID" ]; then
    echo "Error: Could not find CloudFront Distribution ID. Make sure the stack is deployed."
    exit 1
fi

# S3にファイルを同期
echo "Syncing files to S3..."
aws s3 sync $SOURCE_DIR s3://$BUCKET_NAME/ \
    --exclude "*" \
    --include "*.html" \
    --include "*.svg" \
    --include "*.png" \
    --include "*.jpg" \
    --include "*.jpeg" \
    --include "*.gif" \
    --include "*.css" \
    --include "*.js" \
    --include "docs/*" \
    --exclude ".git/*" \
    --exclude "cloudformation/*" \
    --exclude ".claude/*" \
    --exclude "README.md" \
    --exclude "CLAUDE.md" \
    --exclude ".gitignore" \
    --delete \
    --region $REGION \
    $AWS_PROFILE_ARG

# HTMLファイルのContent-Typeを設定
echo "Setting Content-Type for HTML files..."
aws s3 cp s3://$BUCKET_NAME/ s3://$BUCKET_NAME/ \
    --exclude "*" \
    --include "*.html" \
    --content-type "text/html; charset=utf-8" \
    --metadata-directive REPLACE \
    --recursive \
    --region $REGION \
    $AWS_PROFILE_ARG

# SVGファイルのContent-Typeを設定
echo "Setting Content-Type for SVG files..."
aws s3 cp s3://$BUCKET_NAME/ s3://$BUCKET_NAME/ \
    --exclude "*" \
    --include "*.svg" \
    --content-type "image/svg+xml" \
    --metadata-directive REPLACE \
    --recursive \
    --region $REGION \
    $AWS_PROFILE_ARG

# CloudFrontのキャッシュを無効化
echo "Invalidating CloudFront cache..."
aws cloudfront create-invalidation \
    --distribution-id $CLOUDFRONT_ID \
    --paths "/*" \
    --region $REGION \
    $AWS_PROFILE_ARG

echo "=========================================="
echo "Sync Complete!"
echo "CloudFront Distribution ID: $CLOUDFRONT_ID"
echo "=========================================="