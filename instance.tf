# data "template_file" "setup_db" {
#   template = file("./db-server/setup.sh")

#   vars = {
#     database_name = var.database_name
#     database_user = var.database_user
#     database_pass = var.database_pass
#     admin_user    = var.admin_user
#     admin_pass    = var.admin_pass
#   }
# }

# resource "aws_instance" "db_server" {
#   ami           = var.ami
#   instance_type = "t2.micro"

#   user_data = <<-EOF
#     ${data.template_file.setup_db.rendered}
#     EOF

#   network_interface {
#     device_index         = 0
#     network_interface_id = aws_network_interface.db_server.id
#   }

#   network_interface {
#     device_index         = 1
#     network_interface_id = aws_network_interface.private_2_db.id
#   }

#   tags = {
#     Name = "NextcloudDbServer"
#   }
# }

# resource "aws_instance" "app_server" {
#   ami           = var.ami
#   instance_type = "t2.micro"
#   key_name      = var.key_name

#   network_interface {
#     device_index         = 0
#     network_interface_id = aws_network_interface.app_server.id
#   }

#   network_interface {
#     device_index         = 1
#     network_interface_id = aws_network_interface.private_2_app.id
#   }

#   tags = {
#     Name = "NextcloudAppServer"
#   }
# }

# data "template_file" "setup_app" {
#   depends_on = [aws_eip.app_server, aws_iam_access_key.s3, aws_s3_bucket.bucket]
#   template   = file("./app-server/setup.sh")

#   vars = {
#     database_name = var.database_name
#     database_user = var.database_user
#     database_pass = var.database_pass
#     admin_user    = var.admin_user
#     admin_pass    = var.admin_pass
#     public_ip     = aws_eip.app_server.public_ip
#     s3_key        = aws_iam_access_key.s3.id
#     s3_secret     = aws_iam_access_key.s3.secret
#   }
# }

# data "template_file" "app_storage_config" {
#   depends_on = [aws_iam_access_key.s3, aws_s3_bucket.bucket]
#   template   = file("./app-server/storage.config.php")

#   vars = {
#     bucket_name        = var.bucket_name
#     bucket_domain_name = aws_s3_bucket.bucket.bucket_domain_name
#     region             = aws_s3_bucket.bucket.region
#     s3_key             = aws_iam_access_key.s3.id
#     s3_secret          = aws_iam_access_key.s3.secret
#   }
# }

# resource "null_resource" "init_app_server" {
#   depends_on = [aws_instance.app_server, aws_instance.db_server, aws_eip.app_server]

#   connection {
#     type = "ssh"
#     user = "ubuntu"
#     host = aws_eip.app_server.public_ip
#   }

#   provisioner "file" {
#     source      = "./app-server/nextcloud.conf"
#     destination = "/tmp/nextcloud.conf"
#   }

#   provisioner "file" {
#     content     = data.template_file.setup_app.rendered
#     destination = "/tmp/setup.sh"
#   }

#   provisioner "file" {
#     content     = data.template_file.app_storage_config.rendered
#     destination = "/tmp/storage.config.php"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /tmp/setup.sh",
#       "/tmp/setup.sh",
#     ]
#   }
# }