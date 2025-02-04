ec2_specs = {
  ami           = "ami-05576a079321f21f8"
  instance_type = "t2.micro"
}

tags = {
  "env"         = "dev"
  "owner"       = "Imunoz"
  "cloud"       = "AWS"
  "IAC"         = "Terraform"
  "IAC_Version" = "1.9.5"
  "project"     = "pegaso"
  "region"      = "virginia"
}

virginia_cidr = "10.0.0.0/16"

sg_ingress_cidr = "0.0.0.0/0"

ingress_ports_list = [22, 80, 443, 8080, 9000]

subnets = ["10.0.1.0/24", "10.0.2.0/24"]