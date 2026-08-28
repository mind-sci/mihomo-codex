FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ENV CUDA_HOME=/usr/local/cuda
ENV CONDA_DIR=/opt/conda
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 更换源（可选）
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装基础依赖 + NVIDIA GPU 支持
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    openssh-server \
    sudo \
    vim \
    git \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# 安装 Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p ${CONDA_DIR} && ${CONDA_DIR}/bin/conda init && rm /tmp/miniconda.sh

# 配置 SSH：允许 root 登录，使用密钥
RUN mkdir /var/run/sshd && \
    mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
    sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    ssh-keygen -A

RUN echo 'LANG=C.UTF-8' >> /etc/default/locale && \
    echo 'LC_ALL=C.UTF-8' >> /etc/default/locale && \
    echo "export CUDA_HOME=${CUDA_HOME}" >> /etc/bash.bashrc && \
    echo "export CONDA_DIR=${CONDA_DIR}" >> /etc/bash.bashrc && \
    echo 'export PATH=${CUDA_HOME}/bin:/root/.local/bin:${PATH}' >> /etc/bash.bashrc && \
    echo 'export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}' >> /etc/bash.bashrc
COPY ./proxy_alias.sh /etc/profile.d/proxy_alias.sh
COPY ./install.sh /tmp/codex_install.sh
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /tmp/codex_install.sh && chmod +x /entrypoint.sh

# 设置默认工作目录
WORKDIR /root/workspace

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
