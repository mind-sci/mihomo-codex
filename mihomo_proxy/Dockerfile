FROM ubuntu:22.04

ARG TARGETARCH=amd64
ARG MIHOMO_VERSION=v1.19.29

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates libnss3 openssh-server sudo && \
    rm -rf /var/lib/apt/lists/*

# 配置 SSH：允许 root 登录，使用密钥
RUN mkdir /var/run/sshd && \
    mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
    sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \    
    ssh-keygen -A
  
# 条件安装：优先使用本地 deb，缺失时联网下载
COPY ./releases /tmp/mihomo_releases
RUN RELEASE_NAME="mihomo-linux-${TARGETARCH}-${MIHOMO_VERSION}.gz"; \
    if [ -f "/tmp/mihomo_releases/$RELEASE_NAME" ]; then \
        echo "使用本地安装文件: $RELEASE_NAME"; \
        mv "/tmp/mihomo_releases/$RELEASE_NAME" "/tmp/$RELEASE_NAME";\
    else \
        echo "本地安装文件不存在，从 GitHub 下载..."; \
        wget -q "https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VERSION}/mihomo-linux-${TARGETARCH}-${MIHOMO_VERSION}.gz" \
             -O "/tmp/$RELEASE_NAME"; \
    fi && \
    rm -rf /tmp/mihomo_releases && cp "/tmp/$RELEASE_NAME" /tmp/mihomo.gz && \
    gzip -d /tmp/mihomo.gz && mv /tmp/mihomo /usr/local/bin/mihomo && \
    chmod +x /usr/local/bin/mihomo

COPY ./entrypoint.sh /entrypoint.sh
RUN echo 'LANG=C.UTF-8' >> /etc/default/locale && \
    echo 'LC_ALL=C.UTF-8' >> /etc/default/locale && \
    chmod +x /entrypoint.sh

# 设置默认工作目录
WORKDIR /etc/mihomo

EXPOSE 22 7890
ENTRYPOINT ["/entrypoint.sh"]
