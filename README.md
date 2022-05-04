# practice-terraform
実践terraform AWSにおけるシステム設計とベストプラクティス


## Set up
### AWS CLI
- create IAM Administrator User
  - property
    - ユーザ名:任意
    - アクセスの種類:プログラムによるアクセス
    - policy: Administrator 
  - `アクセスID`と`シークレットアクセスキー`を控える
- set secret env 
  ```
  $ export AWS_ACCESS_KEY_ID={アクセスID}
  $ export AWS_SECRET_ACCESS_KEY={シークレットアクセスキー}
  $ export AWS_DEFAULT_REGION=ap-north-east-1
  ```
  - 設定されていることを確認
  ```
  $ aws sts get-caller-identity --query Account --output text
  ```