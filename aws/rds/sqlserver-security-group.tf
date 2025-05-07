
resource "aws_security_group" "sqlserver_security_group" {
  count = strcontains(upper(var.engine), "SQLSERVER") ? 1 : 0

  name        = "sqlserver-security-group"
  description = "Security group for RDS MSSQL"
  vpc_id      = var.vpc_id

  tags = {
    Name = "sqlserver-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpn_sqlserver_ingress_rule" {
  count = strcontains(upper(var.engine), "SQLSERVER") && var.create_vpn_rule ? 1 : 0

  from_port         = 1433
  to_port           = 1433
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpn_local_ipv4_cidr
  security_group_id = aws_security_group.sqlserver_security_group[0].id
}

resource "aws_vpc_security_group_ingress_rule" "eks_sqlserver_ingress_rule" {
  count = strcontains(upper(var.engine), "SQLSERVER") && var.create_eks_rule ? 1 : 0

  from_port                    = 1433
  to_port                      = 1433
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.sqlserver_security_group[0].id
  referenced_security_group_id = var.eks_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "sqlserver_egress_rule" {
  count = strcontains(upper(var.engine), "SQLSERVER") ? 1 : 0

  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.sqlserver_security_group[0].id
}