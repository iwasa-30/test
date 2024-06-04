provider "aws" {
  region = "ap-northeast-1"  # 東京リージョンに設定
}


#----------------------------------------
# VPCの作成
#----------------------------------------

resource "aws_vpc" "iwasa_vpc" {
  cidr_block = "${var.vpc_cidr}"
  tags = {
      Name = "${var.mai}"
    }
}

#----------------------------------------
# インターネットゲートウェイの作成
#----------------------------------------

resource "aws_internet_gateway" "iwasa_igw" {
  vpc_id = "${aws_vpc.iwasa_vpc.id}"
  tags = {
      Name = "${var.mai}"
    }
}


#----------------------------------------
# サブネットの作成
#----------------------------------------

resource "aws_subnet" "iwasa_subnet_EC2_1" {
  vpc_id     = "${aws_vpc.iwasa_vpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-1a"  # 利用可能なゾーンに応じて変更
}

resource "aws_subnet" "iwasa_subnet_elb_1" {
  vpc_id     = "${aws_vpc.iwasa_vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"  # 利用可能なゾーンに応じて変更
}

resource "aws_subnet" "iwasa_subnet_elb_2" {
  vpc_id     = "${aws_vpc.iwasa_vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"  # 利用可能なゾーンに応じて変更
}



#----------------------------------------
# ルートテーブルの作成
#----------------------------------------

resource "aws_route_table" "iwasa_route_table_elb" {
  vpc_id = "${aws_vpc.iwasa_vpc.id}"
}

resource "aws_route_table" "iwasa_route_table_EC2" {
  vpc_id = "${aws_vpc.iwasa_vpc.id}"
}



resource "aws_route" "iwasa_elb_route" {
  route_table_id         = "${aws_route_table.iwasa_route_table_elb.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.iwasa_igw.id}"
}

resource "aws_route" "iwasa_EC2_route" {
  route_table_id         = "${aws_route_table.iwasa_route_table_EC2.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.iwasa_igw.id}"
}


#----------------------------------------
# ルートテーブルとサブネット関連付け
#----------------------------------------



resource "aws_route_table_association" "iwasa_subnet_association_EC2_1" {
  subnet_id      = "${aws_subnet.iwasa_subnet_EC2_1.id}"
  route_table_id = "${aws_route_table.iwasa_route_table_EC2.id}"
}

resource "aws_route_table_association" "iwasa_subnet_association_elb_1" {
  subnet_id      = "${aws_subnet.iwasa_subnet_elb_1.id}"
  route_table_id = "${aws_route_table.iwasa_route_table_elb.id}"
}

resource "aws_route_table_association" "iwasa_subnet_association_elb_2" {
  subnet_id      = "${aws_subnet.iwasa_subnet_elb_2.id}"
  route_table_id = "${aws_route_table.iwasa_route_table_elb.id}"
}

