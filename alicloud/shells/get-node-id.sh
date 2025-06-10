#!/bin/bash
eval "$(jq -r '@sh "DB_INSTANCE_ID=\(.dbInstanceId)"')"
aliyun rds DescribeDBInstanceAttribute --DBInstanceId $DB_INSTANCE_ID | jq -r '.Items.DBInstanceAttribute[0].DBClusterNodes.DBClusterNode[] | select(.NodeRole=="secondary")'