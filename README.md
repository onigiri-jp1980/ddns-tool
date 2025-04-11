# microDDNS
## 概要
- どういうツールなの？
  - 自前でダイナミックDNSを構築するためのツールです。
- 世の中にはダイナミックDNSがいっぱいあるのになんで作ったの？
  - ほぼすべてのダイナミックDNSで自営ドメインを運用するには課金が必要だったりドメイン取る費用が割高なところしか無いので、「せっかく自前でAWS使ってるんだからどうにかできないかな」って長年思ってましたが、AWSでのサーバレスアプリとterraformの勉強がてら作ってみたものです。
- サクッと試せない？
  - わたしの手持ちドメインで試していただけるようにしてみようかな、って思いましたがゆくゆくはお小遣い稼ぎのネタにしたいのでそこは現状考えてないです。
- コード汚くない？？
  - インフラエンジニアが頑張ってChatGPTさんと編んだコードなのでそんないけず言わないでください笑

## 必要なもの
 - AWSアカウント【必須】
   - 以下の情報がのご用意が必要となります。
     - アカウントID
     - APIアクセスキー／シークレットキー
   - microDDNSを使いたいドメインのRoute53のホストゾーンがあること
 - 自営ドメイン
   - 「先述のAWSアカウントのRoute53から管理できるドメイン」であることが必要なので、「必須」とはしませんでした。
 - docker-composeの動く環境【必須】
   - macOSでもWSLでもLinuxでも大丈夫なはずです。デプロイ時に、x86-64エミュレーションを使う部分があるのでARM版Linuxとかでやりたい場合は適宜工夫してください。僕にはサポートは厳しいです。

## デプロイ方法
今回、APIを動作させるAWS Lambdaには「実在するアプリイメージやパッケージがないと構築ができない」という
自動構築のハマりどころというがあるので、本アプリにおいては以下の流れで感じでデプロイしていただくことになります。
1. 作業環境の準備
1. AWS側の環境構築(前半)
1. アプリイメージをビルド(構築)してプッシュ(登録)
1. AWS側の環境構築(後半)

ほぼコンテナ内を触る必要はほぼないですが、以降ホストOS側の作業とコンテナ内での作業は以下のように表記します。

- `(your host)$`: ホストOS
  - 基本的にはクローンしたディレクトリ配下での作業です。
- `(コンテナ名)$`: コンテナ内

### Step1. 作業環境の準備
各作業用コンテナの初期設定を行います。
#### 設定ファイルの用意
設定ファイルのサンプルをコピーして、それぞれコメントに従って編集してください。
```bash
(your host)$ cp .env.example .env
(your host)$ cp .env.example terraforom/terraform.tfvars
```

#### 作業用コンテナの準備
```bash
(your host)$ docker compose build
(your host)$ docker compose run --rm terraform init
```

### Step2. AWS側の環境構築(前半)
アプリイメージを格納するECRリポジトリのみを先に作っておきます
```bash
(your host)$ docker compose run --rm terraform apply -target=aws_ecr_repository.app_repository
#AWS側に作るものがバーっと表示されて、以下のような確認が出ます。
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: #`yes`と入力してください
```

### Step.3 アプリイメージをビルド(構築)してプッシュ(登録)
#### ECRとdockerを連携
aws-cliに`--profile`などを適宜付けてデプロイ先のAWSアカウントを指定してあげてください。
``` bash
(your host)$ aws ecr get-login-password --region (デプロイ先のAWSリージョン) | docker login --username AWS --password-stdin (デプロイ先のAWSアカウントID).dkr.ecr.ap-northeast-1.amazonaws.com
``` 

#### アプリイメージのビルドとプッシュ
``` bash
(your host)$ docker compose -f docker-compose.deploy.yml build
(your host)$ docker compose -f docker-compose.deploy.yml push

```

### Step.4 AWS側の環境構築(後半)
ECRリポジトリ以外のリソースを作ります。
```bash
(your host)$ docker compose run --rm terraform apply
#AWS側に作るものがバーっと表示されて、以下のような確認が出ます。
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: #`yes`と入力してください
```

## APIの利用方法

以下の例にて使用方法を書きます。

- デプロイ先ホスト名: `api`
- ドメイン名: `mydomain.com`
- microDDNSのAPIキー: `mydomain.com`
- microDDNSでIPアドレスを管理したい自宅サーバ等のホスト名: `server`

### curlでの実行方法
``` bash
$ curl -X POST https://api.mydomain.com/update \
-H 'x-api-key: mydomain.com'
-H 'Content-Type: application/json'
-d '{"hostname":"server","domain":"mydomain.com"}'
```
JSON部分をrequest.jsonとかファイルにして`-d @request.json`にしてもいいでしょうし、
これをシェルスクリプトにしてcronすればいいと思います（なげやり）。

### レスポンス例
#### IPアドレス更新成功の場合
以下の内容がステータコード`200(OK)`で返ってきます
``` json
{
    "detail": "update success."
}
```

#### 更新不要の場合
以下の内容がステータコード`304(Not Modified)`で返ってきます。
``` json
{
    "detail": "not changed. avoiding update."
}
```

#### 更新失敗の場合
ステータスコード`500(Internal server error)`とエラー内容が返ってきます。
