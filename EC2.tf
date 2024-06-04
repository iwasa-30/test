#----------------------------------------
# EC2インスタンスの作成
#----------------------------------------
resource "aws_instance" "001" {
  ami                    = "${var.ami}"
  instance_type          = "t2.micro"
  key_name               = "${var.mai}.c"
  subnet_id              = aws_subnet.iwasa_subnet_EC2_1.id
  private_ip             = "${var.subnet_suffix}.3.10"
  vpc_security_group_ids = [aws_security_group.EC2.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  
  tags = {
    Name = "${var.mai}-001"
  }
  # EBSのルートボリューム設定
  root_block_device {
    # ボリュームサイズ(GiB)
    volume_size = 30
    // EC2終了時にボリュームも削除
    delete_on_termination = false
     # EBSのNameタグ
    tags = {
      Name = "${var.mai}-ebs-001"
    }
  } 
}



resource "aws_instance" "002" {
  ami                    = "${var.ami}"
  instance_type          = "t2.micro"
  key_name               = "${var.mai}.c"
  subnet_id              = aws_subnet.iwasa_subnet_EC2_1.id
  private_ip             = "${var.subnet_suffix}.3.20"
  vpc_security_group_ids = [aws_security_group.EC2.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  
  tags = {
    Name = "${var.mai}-002"
  }
  # EBSのルートボリューム設定
  root_block_device {
    # ボリュームサイズ(GiB)
    volume_size = 30
    // EC2終了時にボリュームも削除
    delete_on_termination = false
     # EBSのNameタグ
    tags = {
      Name = "${var.mai}-ebs-002"
    }
  } 
}







#----------------------------------------
# IAMロールの作成
#----------------------------------------

#インスタンスプロフィール
resource "aws_iam_instance_profile" "instance_profile" {
  name = aws_iam_role.ec2_iam_role.name
  role = aws_iam_role.ec2_iam_role.name
}

# IAM ロールの作成
resource "aws_iam_role" "ec2_iam_role" {
  name               = "iwasa_EC2_CloudwatchAgentRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy.json

   tags = {
   Name = "ApiGatewayS3ProxyCloudWatchLogRole"
  }
}

#信頼ポリシーの作成
data "aws_iam_policy_document" "ec2_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
 }
 
 #ポリシーのアタッチ
  resource "aws_iam_role_policy_attachment" "CloudWatchAgentAdmin_policy" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
}

 resource "aws_iam_role_policy_attachment" "CloudWatchAgentServer_policy" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

 resource "aws_iam_role_policy_attachment" "CloudWatchLogs_full_policy" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

 resource "aws_iam_role_policy_attachment" "AmazonSSM_full_policy" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}



#----------------------------------------
# SG
#----------------------------------------

resource "aws_security_group" "EC2" {
  name        = "EC2-iwasa-sg"
  description = "Allow inbound traffic on port 80 and 443"

  vpc_id =  "${aws_vpc.iwasa_vpc.id}" # 作成するセキュリティグループのVPC ID

  // インバウンドトラフィックの設定
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # どのIPアドレスからでもアクセスを許可
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # どのIPアドレスからでもアクセスを許可
  }

  tags = {
    Name = "EC2-iwasa-sg"
  }
}