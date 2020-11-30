output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public-subnet" {
  value = aws_subnet.public-subnet
}

output "private-subnet" {
  value = aws_subnet.private-subnet
}

output "bastion_id" {
    value = aws_security_group.bastion[0].id
}

output "my-own-ip" {
  value = length(aws_instance.bastionhost[0].public_ip) > 0 ? format("%s/32", chomp(data.http.icanhazip.body)) : ""
}

output "bastion-host-ssh" {
  value = length(aws_instance.bastionhost[0].public_ip) > 0 ? format("ssh -A ec2-user@%s", aws_instance.bastionhost[0].public_ip) : ""
}