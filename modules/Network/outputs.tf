output "vpc_id" {
  value = aws_vpc.prod-vpc.id
}
output "public_subnet" {
  value = aws_subnet.prod-subnet-public.*.id
}


