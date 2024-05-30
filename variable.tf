#project tags
variable "project_name" {
    type = string
}

variable "environment" {
    type = string
    default = "dev"
}

variable "common-tags"{
    type = map
}


# vpc 
variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "enable_dns_name" {
    type = bool
    default = true
}

variable "vpc_tags" {
    type = map
    default = {}
}


# igw tags
variable "igw-tags" {
    type = map
    default = {}
}

# public aws_subnet
variable "public_subnet_cidrs" {
    type = list
    validation {
        condition = length(var.public_subnet_cidrs) == 2
        error_message = "please provide 2 valid public subnet cidr"
    }
}

variable "public_subnet_cidr_tags" {
    type = map
    default = {}
}



variable "private_subnet_cidrs" {
    type = list
    validation {
        condition = length(var.private_subnet_cidrs) == 2
        error_message = "please provide 2 valid public subnet cidr"
    }
}

variable "private_subnet_cidr_tags" {
    type = map
    default = {}
}

variable "database_subnet_cidrs" {
    type = list
    validation {
        condition = length(var.database_subnet_cidrs) == 2
        error_message = "please provide 2 valid public subnet cidr"
    }
}

variable "database_subnet_cidr_tags" {
    type = map
    default = {}
}
variable "nat_gateway_tags" {
    type = map
    default = {}
}
variable "public_route_tags" {
    default = {}
}

variable "private_route_tags" {
    default = {}
}

variable "database_route_tags" {
    default = {}
}
