variable "instancias" {
  description = "Nombre de las instancias"
  type        = list(string)
  default     = ["Jenkins"]
}

resource "aws_instance" "jenkins_ec2" {
  for_each               = toset(var.instancias)
  ami                    = var.ec2_specs.ami
  subnet_id              = aws_subnet.public_subnet.id
  instance_type          = var.ec2_specs.instance_type
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  user_data              = file("scripts/jenkins.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    "Name" = "${each.value}-${local.sufix}"
  }

}