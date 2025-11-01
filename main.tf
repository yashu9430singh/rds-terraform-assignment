provider "aws" {
  region = "us-east-1"
}
 
# --- Existing VPC ---
data "aws_vpc" "existing_vpc" {
  id = "vpc-06ce2d44d302c77e5"  # replace with your actual VPC ID
}
 
# --- Existing Subnets (must be in different AZs) ---
data "aws_subnet" "subnet_1" {
  id = "subnet-027466f48d858db02"  # e.g. us-east-1a
}
 
data "aws_subnet" "subnet_2" {
  id = "subnet-06d0fa94b04ab3f4e"  # e.g. us-east-1b
}
 
 data "aws_subnet" "subnet_3" {
   id = "subnet-08ff27274d591fb1f"  # e.g. us-east-1c
 }
 
# --- DB Subnet Group (at least 2 subnets required) ---
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [
    data.aws_subnet.subnet_1.id,
    data.aws_subnet.subnet_2.id
     ,data.aws_subnet.subnet_3.id
  ]
 
  tags = {
    Name = "rds-subnet-group"
  }
}
 
# --- RDS Instance ---
resource "aws_db_instance" "my_rds" {
  allocated_storage    = 20
  db_name              = "mydatabase"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "MySecurePassword123"
  parameter_group_name = "default.mysql8.0"
 
  # No custom security group → will use default VPC SG
  publicly_accessible  = true
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
 
  tags = {
    Name = "MyLearningRDS"
  }
}
