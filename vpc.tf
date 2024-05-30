resource "aws_vpc"  "main" {
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"
    enable_dns_hostnames = var.enable_dns_name
    tags = merge(
        var.common-tags,
        var.vpc_tags,
        {
        Name = local.resource
    }
    )

}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        var.common-tags,
        var.igw-tags,{
            Name = local.resource
        }
    )
}

resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs)
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = true
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]

  tags = merge(
        var.common-tags,
        var.public_subnet_cidr_tags,
        {
        Name = "${local.resource}-public-${local.az_names[count.index]}"
    }
    )
  }

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
    availability_zone = local.az_names[count.index]
    
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]

  tags = merge(
        var.common-tags,
        var.private_subnet_cidr_tags,
        {
        Name = "${local.resource}-private-${local.az_names[count.index]}"
    }
    )
  }


resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidrs)
    availability_zone = local.az_names[count.index]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]

  tags = merge(
        var.common-tags,
        var.database_subnet_cidr_tags,
        {
        Name = "${local.resource}-database${local.az_names[count.index]}"
    }
    )
  }


### elastic_ip ###
resource "aws_eip" "expense" {
  
  domain   = "vpc"
}

### natgateway ###
resource "aws_nat_gateway" "ngt" {
  allocation_id = aws_eip.expense.id

  subnet_id = aws_subnet.public[0].id


  tags = merge(
        var.common-tags,
        var.nat_gateway_tags,
        {
        Name = "${local.resource}"
    }
    )
    depends_on = [aws_internet_gateway.gw]
  }


  resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.main.id
   tags = merge(
        var.common-tags,
        var.public_route_tags,
        {
        Name = "${local.resource}-public"
    }
    )
}
resource "aws_route_table" "private_table" {
  vpc_id = aws_vpc.main.id
   tags = merge(
        var.common-tags,
        var.private_route_tags,
        {
        Name = "${local.resource}-private"
    }
    )
}

resource "aws_route_table" "database_table" {
  vpc_id = aws_vpc.main.id
   tags = merge(
        var.common-tags,
        var.database_route_tags,
        {
        Name = "${local.resource}-database"
    }
    )
}


resource "aws_route" "public_route" {
    route_table_id = aws_route_table.public_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route" "private_route" {
    route_table_id = aws_route_table.private_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngt.id
}

resource "aws_route" "databse_route" {
    route_table_id = aws_route_table.database_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngt.id
}


### subnet assocition with route table ###
resource "aws_route_table_association" "public-association" {
    count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_table.id
}
resource "aws_route_table_association" "private_association" {
    count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_table.id
}

resource "aws_route_table_association" "database_association" {
    count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database_table.id
}
