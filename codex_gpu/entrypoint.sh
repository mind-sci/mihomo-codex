#!/bin/bash
set -e

# 配置 SSH key
if [ ! -f /root/.ssh/authorized_keys ]; then
    cp /tmp/authorized_keys /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi

# 保持容器运行
exec /usr/sbin/sshd -D