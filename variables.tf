
# 共通変数定義
variable "vpc_cidr" {
    description = "CIDR Block of VPC"
    type        = string
    default     = "10.0.0.0/16"
}

# 環境名
variable "mai" {
  type = string
  default = "iwasa"
}

# サブネット
variable "subnet_suffix" {
  type = string
  default = "10.0"
}

variable "az1a" {
  type = string
  default = "ap-northeast-1a"
}

variable "az1c" {
  type = string
  default = "ap-northeast-1c"
}

# Amazon Linux 2
variable "ami" {
    type = string
    default = "ami-0ecb2a61303230c9d"
}