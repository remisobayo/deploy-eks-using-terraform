variable "region" {
default = "us-east-2"
}
variable "instance_type" {
default = "t2.medium"
}
variable "instance_key" {
default = "Tolu1991"
}
variable "vpc_cidr" {
default = "178.0.0.0/16"
}
variable "public_subnet1_cidr" {
default = "178.0.10.0/24"
}
variable "public_subnet2_cidr" {
default = "178.0.11.0/24"
}
variable "private_subnet1_cidr" {
default = "178.0.12.0/24"
}
variable "private_subnet2_cidr" {
default = "178.0.13.0/24"
}
variable "availability_zones_count" {
  description = "The number of AZs."
  type        = number
  default     = 2
}

variable "project" {
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
  # description = "mavenapp"
  type = string
}

# variable "vpc_cidr" {
#   description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
#   type        = string
#   default     = "10.0.0.0/16"
# }

# variable "subnet_cidr_bits" {
#   description = "The number of subnet bits for the CIDR. For example, specifying a value 8 for this parameter will create a CIDR with a mask of /24."
#   type        = number
#   default     = 8
# }

# variable "tags" {
#   description = "A map of tags to add to all resources"
#   type        = map(string)
#   default = {
#     "Project"     = "TerraformEKSWorkshop"
#     "Environment" = "Development"
#     "Owner"       = "Ashish Patel"
#   }
# }