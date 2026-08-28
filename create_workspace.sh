#!/bin/bash
set -e

# 检查参数
if [ $# -ne 2 ]; then
    echo "Usage: $0 <workspace_name> <ssh_port>"
    echo "Example: $0 main 22002"
    exit 1
fi

# 切换到脚本自身所在的目录
cd "$(dirname "$0")"

WORKSPACE_NAME="$1"
SSH_PORT="$2"
CONTAINER_NAME="codex_gpu_${WORKSPACE_NAME}"
IMAGE_NAME="codex-gpu:1.0"
NETWORK_NAME="proxy-net"
WORKSPACE_DIR="${HOME}/Workspaces/${WORKSPACE_NAME}"

# 检查 SSH 端口是否合法
if ! [[ "$SSH_PORT" =~ ^[0-9]+$ ]] || [ "$SSH_PORT" -lt 1 ] || [ "$SSH_PORT" -gt 65535 ]; then
    echo "Error: invalid SSH port: $SSH_PORT"
    exit 1
fi

# 检查同名容器是否已经存在
if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
    echo "Error: container '$CONTAINER_NAME' already exists."
    echo "Remove it first with:"
    echo " docker rm -f $CONTAINER_NAME"
    exit 1
fi

echo "Starting container: $CONTAINER_NAME"
echo "Workspace: $WORKSPACE_DIR"
echo "SSH port: $SSH_PORT"

docker run -d \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    --gpus all \
    -e MIHOMO_HTTP_PROXY=http://mihomo_proxy:7890 \
    -e MIHOMO_HTTPS_PROXY=http://mihomo_proxy:7890 \
    -e MIHOMO_ALL_PROXY=socks5://mihomo_proxy:7890 \
    -e MIHOMO_NO_PROXY=localhost,127.0.0.1,.local \
    -p "${SSH_PORT}:22" \
    -v "./authorized_keys:/tmp/authorized_keys:ro" \
    -v "$WORKSPACE_DIR:/root/workspace" \
    -v "${HOME}/Share:/root/share" \
    --network "$NETWORK_NAME" "$IMAGE_NAME"

echo "Container '$CONTAINER_NAME' started successfully."

