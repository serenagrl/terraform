#!/bin/bash

git clone -n --depth=1 --filter=tree:0 https://github.com/AliyunContainerService/ack-secret-manager.git /tmp/ack-secret-manager
cd /tmp/ack-secret-manager
git sparse-checkout set --no-cone /charts/ack-secret-manager/
git checkout
mv charts/ack-secret-manager/* .
rm -r charts/ack-secret-manager/