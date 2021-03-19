provider "aws" {
  region  = "ap-south-1"
  profile = "Rohit"
}


// creating a key
resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
}

//Generating Key-Value Pair
resource "aws_key_pair" "generated_key" {
  key_name   = "rg-env-key"
  public_key = "${tls_private_key.tls_key.public_key_openssh}"
  
  depends_on = [
    tls_private_key.tls_key
  ]
}


//Saving Private Key PEM File
resource "local_file" "key-file" {
  content  = "${tls_private_key.tls_key.private_key_pem}"
  filename = "rg-env-key.pem"
  
  depends_on = [
    tls_private_key.tls_key
  ]
}

//Creating Variable for AMI_ID
variable "ami_id" {
  type    = string
  default = "ami-0b84c6433cdbe5c3e"
}

//Creating Variable for AMI_Type
variable "ami_type" {
  type    = string
  default = "t2.large"
}

//Creating Security Group
resource "aws_security_group" "RASA-SG" {
  name        = "Terraform-SG"
  description = "RASA Environment Security Group"


  //Adding Rules to Security Group 
  ingress {
    description = "SSH Rule"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "HTTP Rule"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//Launching ubuntu Instance
resource "aws_instance" "rasa" {
  ami             = "${var.ami_id}"
  instance_type   = "${var.ami_type}"
  key_name        = "${aws_key_pair.generated_key.key_name}"
  security_groups = ["${aws_security_group.RASA-SG.name}","default"]

  //Labelling the Instance
  tags = {
    Name = "RASA-Env"
    env  = "Production"
  } 

  depends_on = [
    aws_security_group.RASA-SG,
    aws_key_pair.generated_key
  ]
}

// running commands using the null resource, local_exec, remote_exec, and Volume to store data

resource "null_resource" "remote1" {
  
  depends_on = [ aws_instance.rasa, ]
  //Executing Commands to initiate WebServer in Instance Over SSH 
  provisioner "remote-exec" {
    connection {
      agent       = "false"
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${tls_private_key.tls_key.private_key_pem}"
      host        = "${aws_instance.rasa.public_ip}"
    }
    inline = [
      "sudo apt-get update",
      "sudo apt-get install python3",
      "sudo apt-get install python3-pip python3-apt python3-distutils -y",
      "curl -sSL -o install.sh https://storage.googleapis.com/rasa-x-releases/0.35.1/install.sh",
      "YES y | sudo bash ./install.sh",
      "cd /etc/rasa",
      "sudo docker-compose up -d",
      "sudo python3 rasa_x_commands.py create admin me 123456"
    ]


}

}

//Creating EBS Volume
resource "aws_ebs_volume" "web-vol" {
  availability_zone = "${aws_instance.rasa.availability_zone}"
  size              = 100
  
  tags = {
    Name = "ebs-vol"
  }
}


//Attaching EBS Volume to a Instance
resource "aws_volume_attachment" "ebs_att" {
  device_name  = "/dev/sdh"
  volume_id    = "${aws_ebs_volume.web-vol.id}"
  instance_id  = "${aws_instance.rasa.id}"
  force_detach = true 


  provisioner "remote-exec" {
    connection {
      agent       = "false"
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${tls_private_key.tls_key.private_key_pem}"

      host        = "${aws_instance.rasa.public_ip}"
    }
    
    inline = [
     
    ]
  }


  depends_on = [
    aws_instance.rasa,
    aws_ebs_volume.web-vol
  ]
}
