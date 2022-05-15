// provider:cloud APIの明示
provider "aws" {
  region = "ap-northeast-1"
}


// # パブリックネットワーク
// ## VPC - 他のネットワークから論理的に切り離されている仮想ネットワーク
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16" 
  enable_dns_support = true // 名前解決
  enable_dns_hostnames = true

  tags = {
    "Name" = "example"
  }
}

// ## パブリックサブネット
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a" // リージョン内の複数のロケーション
}

// ## インターネットゲートウェイ
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

// ## ルートテーブル
// ネットワークにデータを流すため、ルーティング情報を管理するルートテーブルが必要
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id
}

// ルートテーブルは少し特殊な仕様がある。
// VPC内の通信を有効にするため、ローカルルートが自動的に作成される
// ローカルルートは変更や削除ができず、Terraformからも削除ができない

// ルート
// ルートはルートテーブルの1レコードに該当
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.example.id
  // VP以外への通信をインターネットゲートウェイ経由でインターネットへデータを流すために、デフォルトルート(0.0.0.0/0)をdestination_cidr_blockに指定する
  destination_cidr_block = "0.0.0.0/0"
}

// ルートテーブルの関連付け
// 関連付けを忘れた場合は、デフォルトルートテーブルが自動的に使われる(アンチパターン)
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

// # プライベートネットワーク
// インターネットから隔離されたネットワーク
// DBサーバのような、インターネットからアクセスしないリソースを配置する

// ## プライベートサブネット
// - サブネット
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.64.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = false
}

// - ルートテーブルと関連付け
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

// ### NATゲートウェイ
// NAT(Nwtwork Address Translation)サーバを導入すると、プライベートネットワークからインターネットへアクセスできるようになる。

// - EIP
// NATゲートウェイにはEIP(Elastic IP Address)が必要
// EIPは静的なパブリックIPアドレスを付与するサービス
resource "aws_eip" "nat_gateway" {
  vpc = true
  depends_on = [aws_internet_gateway.example]
}

// - NATゲートウェイge-touxei

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.public.id
  depends_on = [
    aws_internet_gateway.example
  ]
}
