resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${local.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_rtb1.id, aws_route_table.private_rtb2.id]

  tags = {
    Name = "${local.project}-vpce-s3"
  }
}