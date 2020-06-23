provider "aws" {
  region = "us-east-1"
}

# Get the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic*"]
  }
}

resource "aws_spot_instance_request" "web_server" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.image_id
  availability_zone      = "us-east-1f"
  instance_type          = "t3a.nano"
  key_name               = var.key_name
  spot_price             = "0.0015"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
#!/bin/bash
# log output
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

printf "\n\nNoninteractive update and upgrades..."
apt update 
DEBIAN_FRONTEND='noninteractive' apt -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade
DEBIAN_FRONTEND='noninteractive' apt -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade

printf "\n\nInstall server..."
apt install php-cli -y

printf "\n\nClean and autoremove apt cache..."
apt clean && apt autoremove -y

#echo "Hello, World (terraform-example)<br /><br /><?php echo 'Connected to host: ', gethostname(), ' - From: ', \$_SERVER['REMOTE_ADDR']; ?>" > /home/ubuntu/index.php

# Create Systemd service and start onboot
printf "\n\nCreating web app system service..."
tee /lib/systemd/system/myapp.service <<SERVICE
[Unit]
Description=AWS Interview Process
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/home/ubuntu
ExecStart=/usr/bin/php -S 0.0.0.0:80 -t /home/ubuntu/server/
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=always
RestartSec=5

StandardOutput=file:/home/ubuntu/access.log
StandardError=file:/home/ubuntu/webapp_error.log

[Install]
WantedBy=multi-user.target
SERVICE
systemctl daemon-reload
systemctl restart myapp
systemctl enable myapp.service

# Create index file for web server
printf "\n\nCreating index.html..."
mkdir -p /home/ubuntu/server
cd /home/ubuntu
echo "<html><head><title>AWS Test Instance</title></head><body><h2>Hello AWS World!</h2><p>From: $${HOSTNAME}</p></body></html>" > server/index.html


# Start one-liner web server
php -S 0.0.0.0:80 -t /home/ubuntu/server/ > access.log 2>&1 &
#nohup busybox httpd -f -p 8080 &

printf "\n\nFinished setting up..."

reboot
  EOF

  tags = {
    Name         = var.app_name
    Description  = "testing out fastly"
    Organization = "Antmounds"
    Department   = "Engineering"
    Team         = "DevOps"
    Owner        = var.owner
    Provisioner  = "Terraform"
    App          = var.app_name
  }

  volume_tags = {
    Name         = var.app_name
    Description  = "testing out fastly"
    Organization = "Antmounds"
    Department   = "Engineering"
    Team         = "DevOps"
    Owner        = var.owner
    Provisioner  = "Terraform"
    App          = var.app_name
  }
}

resource "aws_security_group" "instance" {
  name        = "terraform-managed-sg"
  description = "Managed by Terraform - Allows SSH, HTTP/S & ICMP"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "app_ip" {
  count    = length(aws_spot_instance_request.web_server)
  instance = element(aws_spot_instance_request.web_server.*.spot_instance_id, count.index)
  vpc      = true

  tags = {
    Name        = "Web App EIP"
    Description = "Elastic IP for web app"
    Owner       = var.owner
    Creator     = "Terraform"
  }
}

output "public_ip" {
  value = aws_spot_instance_request.web_server.*.public_ip
}

output "elastic_ip" {
  value = aws_eip.app_ip.*.public_ip
}

output "public_dns" {
  value = aws_spot_instance_request.web_server.*.public_dns
}