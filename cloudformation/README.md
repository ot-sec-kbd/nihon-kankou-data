# AWS S3 静的ウェブサイトホスティング

このディレクトリには、Japan 47 GO 観光情報データ利用ページをAWS S3で公開するためのCloudFormationテンプレートとデプロイスクリプトが含まれています。

## 構成

- **S3バケット**: 静的ウェブサイトホスティング用
- **CloudFront**: CDN配信とHTTPS対応
- **バケットポリシー**: パブリック読み取りアクセス許可

## ファイル説明

- `s3-static-website.yaml`: CloudFormationテンプレート
- `deploy.sh`: CloudFormationスタックのデプロイスクリプト
- `sync-s3.sh`: コンテンツをS3に同期するスクリプト

## 使用方法

### 1. 初回デプロイ

```bash
# 実行権限を付与
chmod +x deploy.sh sync-s3.sh

# デフォルトプロファイルでSTG環境にデプロイ
./deploy.sh STG

# 特定のAWSプロファイルを使用してSTG環境にデプロイ
./deploy.sh STG myprofile

# PROD環境にデプロイ
./deploy.sh PROD production-profile
```

### 2. コンテンツの同期

```bash
# デフォルトプロファイルでSTG環境に同期
./sync-s3.sh STG

# 特定のAWSプロファイルを使用してSTG環境に同期
./sync-s3.sh STG myprofile

# PROD環境に同期
./sync-s3.sh PROD production-profile
```

### AWSプロファイルの設定

複数のAWSアカウントを使用する場合は、`~/.aws/credentials`にプロファイルを設定してください：

```ini
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY

[myprofile]
aws_access_key_id = ANOTHER_ACCESS_KEY
aws_secret_access_key = ANOTHER_SECRET_KEY

[production-profile]
aws_access_key_id = PROD_ACCESS_KEY
aws_secret_access_key = PROD_SECRET_KEY
```

## バケット名

- STG環境: `stg-japan47go-nihon-kankou-data`
- PROD環境: `prod-japan47go-nihon-kankou-data`

## 注意事項

- AWS CLIがインストールされ、適切な権限が設定されている必要があります
- デフォルトリージョンは `ap-northeast-1` (東京) です
- CloudFrontのキャッシュは同期時に自動的に無効化されます

## 必要な権限

以下のAWS権限が必要です：

- S3: バケット作成、オブジェクト操作
- CloudFormation: スタック作成・更新
- CloudFront: ディストリビューション作成・無効化
- IAM: CloudFront Origin Access Identity作成