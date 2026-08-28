#!/bin/bash
set -e

# 配置 SSH key
if [ ! -f /root/.ssh/authorized_keys ]; then
    cp /tmp/authorized_keys /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi

# 启动 sshd
/usr/sbin/sshd

# 启动 mihomo
exec mihomo -d /etc/mihomo