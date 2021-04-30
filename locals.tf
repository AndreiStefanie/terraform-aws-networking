locals {
  any_ip = "0.0.0.0/0"
}

locals {
  security_groups = {
    public = {
      name        = "public_sg"
      description = "public access"
      ingress = {
        open = {
          from_port   = 0
          to_port     = 0
          protocol    = -1
          cidr_blocks = [var.access_ip]
        }
        tg = {
          from_port   = 8000
          to_port     = 8000
          protocol    = "tcp"
          cidr_blocks = [local.any_ip]
        }
        http = {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = [local.any_ip]
        }
      }
    }
    rds = {
      name        = "rds_sg"
      description = "rds access"
      ingress = {
        mysql = {
          from_port   = 3306
          to_port     = 3306
          protocol    = "tcp"
          cidr_blocks = ["10.123.0.0/16"]
        }
      }
    }
  }
}
