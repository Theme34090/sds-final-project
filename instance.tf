resource "aws_instance" "db_server" {
  ami           = var.ami
  instance_type = "t2.micro"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.db_server.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.private_2_db.id
  }

  user_data = <<-EOF
    ${templatefile("${path.module}/scripts/setup_db.sh", {
  database_name = var.database_name,
  database_user = var.database_user,
  database_pass = var.database_pass,
  admin_user    = var.admin_user,
  admin_pass    = var.admin_pass,
})}
    EOF

tags = {
  Name = "NextcloudDbServer"
}
}

resource "aws_instance" "app_server" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.app_server.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.private_2_app.id
    device_index         = 1
  }

  depends_on = [aws_eip.app_server, aws_iam_access_key.s3, aws_s3_bucket.bucket]

  user_data = <<-EOF
    #!/bin/bash
    echo '${file("${path.module}/scripts/nextcloud.conf")}' > /tmp/nextcloud.conf
    echo '${templatefile("${path.module}/scripts/storage.config.php", {
  bucket_name = var.bucket_name,
  region      = aws_s3_bucket.bucket.region,
  s3_key      = aws_iam_access_key.s3.id,
  s3_secret   = aws_iam_access_key.s3.secret,
  })}' > /tmp/storage.config.php
      echo '${templatefile("${path.module}/scripts/setup_app.sh", {
  database_name = var.database_name,
  database_user = var.database_user,
  database_pass = var.database_pass,
  admin_user    = var.admin_user,
  admin_pass    = var.admin_pass,
  public_ip     = aws_eip.app_server.public_ip,
})}' > /tmp/setup.sh
    chmod +x /tmp/setup.sh
    /tmp/setup.sh
    EOF

tags = {
  Name = "NextcloudAppServer"
}
}