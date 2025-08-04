resource "aws_vpc" "llm_inference_api_vpc" {
    cidr_block = "10.0.0/16"
    enable_dns_support = true
    instance_tenancy = default 
    enable_dns_hostnames = true
    tags = {
        Name = "llm-inference-api-vpc"

    }
}

resource "aws_subnet" "public_llm_inference_api_subnet" {
    for_each = var.public_subnets
    vpc_id = aws_vpc.llm_inference_api_vpc.id 
    cidr_block = cidrsubnet(aws_vpc.llm_inference_api_vpc.cidr_block, 8, each.value)
    tags = {
    Name                                   = "public-${each.key}"
    "kubernetes.io/role/elb"               = "1"
    "kubernetes.io/cluster/secure_cluster" = "owned"
  }

}


resource "aws_subnet" "private_llm_inference_api_subnet" {
    for_each = var.private_subnets
    vpc_id = aws_vpc.llm_inference_api_vpc.id 
    cidr_block = cidrsubnet(aws_vpc.llm_inference_api_vpc.cidr_block, 8, each.value)
    tags = {
    Name                                   = "private-${each.key}"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/secure_cluster" = "owned"
  }

}

resource "aws_internet_gateway" "llm_inference_api_igw" {
    vpc_id = aws_vpc.llm_inference_api_vpc.id
    tags = {
        Name = "llm-inference-api-igw"
    }

}

resource "aws_route_table" "llm_inference_api_public_route_table" {
    vpc_id = aws_vpc.llm_inference_api_vpc.id
    route {
        cidr_block =  "0.0.0/0"
        gateway_id = aws_internet_gateway.llm_inference_api_igw.id
    }

    tags = {
      Name = "llm-inference-api-public-route-table"
    }
}

resource "aws_route_table" "llm_inference_api_private_route_table" {
    vpc_id = aws_vpc.llm_inference_api_vpc.id
    route {
        cidr_block =  "0.0.0/0"
        nat_gateway_id = aws_nat_gateway.llm_inference_api_nat.id
    }

    tags = {
      Name = "llm-inference-api-public-route-table"
    }
}

resource "aws_nat_gateway" "llm_inference_api_nat" {
    allocation_id = aws_eip.llm_inference_api_eip.id
    subnet_id = aws_subnet.public_llm_inference_api_subnet["us-east-1a"].id
    depends_on = [aws_internet_gateway.llm_inference_api_igw]
    tags = {
        Name = "llm-inference-api-nat"
    }
}



resource "aws_eip" "llm_inference_api_eip" {
    depends_on = [aws_internet_gateway.llm_inference_api_igw]
    domain = "vpc"
}


resource "aws_route_table_association" "llm_inference_api_public_route_table_association" {
    depends_on = [ aws_subnet.public_llm_inference_api_subnet ]
    for_each = aws_subnet.public_llm_inference_api_subnet
    subnet_id = each.value.id
    route_table_id = aws_route_table.llm_inference_api_public_route_table.id
}


resource "aws_route_table_association" "llm_inference_api_private_route_table_association" {
    for_each = aws_subnet.private_llm_inference_api_subnet
    depends_on = [aws_subnet.private_llm_inference_api_subnet]
    subnet_id = each.value.id
    route_table_id = aws_route_table.llm_inference_api_private_route_table.id
}