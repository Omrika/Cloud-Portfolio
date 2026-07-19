resource "aws_instance" "my_first_server" {
  ami           = "ami-0d001f8052688dc45"
  instance_type = "t3.micro"

  tags = {
    Name = "TKH-Phase2-Instance"
  }
}