resource "aws_instance" "example" {
  # Run an Ubuntu 18.04 AMI on the EC2 instance.
  ami                    = "ami-0747bdcabd34c712a"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name = "anz_demo"

  # When the instance boots, start a web server on port 8080 that responds with "Hello, World!".
  user_data = <<EOF
#!/bin/bash
echo "Hello, World!" > index.html
nohup busybox httpd -f -p 8080 &
EOF

  provisioner "local-exec" {

    command = "sleep 60s;chmod 600 anz_demo.pem;ANSIBLE_HOST_KEY_CHECKING False ansible-playbook -u ec2-user -i '${aws_instance.example.public_ip},' --private-key anz_demo.pem playbook.yml"
  }
}

# Allow the instance to receive requests on port 8080.
resource "aws_security_group" "instance" {
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Output the instance's public IP address.
output "public_ip" {
  value = aws_instance.example.public_ip
}
