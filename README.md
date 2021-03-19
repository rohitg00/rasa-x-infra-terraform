# rasa-x-infra-terraform
Terraform script to launch RASA X on AWS with just one click.

# Must Follow below given steps to set-up this infrastructure successfully

## Version
- AWS Version: AWS-CLI V2.0
- RASA-X Version: 35.01 release

## Step 1 : Install aws and terraform in your PC
- Storage: EBS Volume - 100GB
- OS: ubuntu:18.04
- Instance type: t2.large

## Step 2: Configure aws user in your PC
- Follow this blog for above steps: [Terraform code to setup Infrastructure on AWS](https://ghumare64.medium.com/terraform-is-a-secret-towards-cloud-automation-%EF%B8%8F-f9c9463b0304)
- Change the profile name in code as per your IAM user
```
provider "aws" {
  region  = "ap-south-1"
  profile = "Rohit" <------------- Change this IAM user
}
```

## Step 3: Once done, Above step for user configuration move to directory where task.tf is stored

## Step 4: Run following commands
```
--> $ terraform init
--> $ terraform plan
--> $ terraform apply --auto-approve
```

## Step 5: Once work done and want to destroy entire infrastructure then use
```
$ terraform destroy --auto-approve
```

# Author
[Rohit Ghumare](https://github.com/rohitg00)

# MIT License
[MIT](https://github.com/rohitg00/FaceRecognizer-VGG16/blob/master/LICENSE)
