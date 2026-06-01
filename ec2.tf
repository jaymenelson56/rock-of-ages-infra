resource "aws_instance" "api_server" {
  count                  = 2 
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_access_instance_profile.name

  subnet_id              = data.aws_subnets.default.ids[0]

  # Attach SG to instance
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  associate_public_ip_address = true

  user_data = templatefile(
    "${path.module}/user_data.sh",
    { account_id = data.aws_caller_identity.current.account_id }
  )

  tags = {
    Name = "rock-of-ages-instance-${count.index}"
    Role = "rock-of-ages-api"
  }
}

resource "aws_lb_target_group_attachment" "api" {
  count            = length(aws_instance.api_server)
  target_group_arn = aws_lb_target_group.api_tg.arn
  target_id        = aws_instance.api_server[count.index].id
  port             = 80
}


data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*kernel-6.1*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}