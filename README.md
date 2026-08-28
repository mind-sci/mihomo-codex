# Mihomo Codex GPU Workspace

> A Docker-based, GPU-enabled development workspace for Codex, with network access routed through Mihomo.

[中文](#中文说明) | [English](#english)

Developed and maintained by **Xinzhi Science (Hangzhou) Co., Ltd.** We build practical AI tools for scientific research.

## English

### Overview

Mihomo Codex GPU Workspace provides a reproducible remote development environment that combines:

- a dedicated [Mihomo](https://github.com/MetaCubeX/mihomo) proxy container;
- an NVIDIA CUDA and cuDNN development container;
- SSH key-based access;
- Miniconda, Git, Vim, and tmux;
- optional proxy environment variables for Codex and other command-line tools; and
- persistent workspace and shared-data mounts.

The two containers communicate over an isolated Docker bridge network. Proxy variables are available inside the GPU container but are only enabled in an interactive shell when you run `proxyon`.

### Architecture

```text
Host
├── :22001 ──> mihomo_proxy:22
├── :7890  ──> mihomo_proxy:7890
└── :22002 ──> codex_gpu:22
                  │
                  └── proxy-net ──> mihomo_proxy:7890
```

### Prerequisites

- Docker Engine with Docker Compose
- An NVIDIA GPU with a compatible driver
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
- An SSH key pair
- A valid Mihomo configuration

### Quick start

1. Clone the repository and enter its directory.

   ```bash
   git clone <repository-url>
   cd mihomo_codex
   ```

2. Add your SSH public key to `authorized_keys`.

   ```bash
   cp ~/.ssh/id_ed25519.pub authorized_keys
   ```

   You may add multiple public keys, one per line. Never place a private key in this repository.

3. Add your Mihomo configuration as `mihomo_proxy/conf/config.yaml`.

   Make sure Mihomo listens on port `7890` and accepts connections from the Docker network. A typical configuration includes:

   ```yaml
   mixed-port: 7890
   allow-lan: true
   bind-address: "*"
   ```

   Add your own proxy providers, nodes, rules, and credentials locally. Do not commit secrets or subscription URLs.

4. Create the host directories mounted by Docker Compose.

   ```bash
   mkdir -p "$HOME/Workspaces/main" "$HOME/Share"
   ```

5. Build and start the services.

   ```bash
   docker compose up -d --build
   docker compose ps
   ```

6. Connect to the GPU workspace.

   ```bash
   ssh -p 22002 root@localhost
   ```

7. Verify GPU access and optionally install Codex.

   ```bash
   nvidia-smi
   bash /tmp/codex_install.sh
   ```

   Restart the shell after installation if the `codex` command is not immediately available.

### Proxy controls

Inside the GPU container, use these shell aliases:

```bash
proxyon   # Enable HTTP, HTTPS, and SOCKS proxy variables
proxyoff  # Clear the proxy variables
```

Test the connection after enabling the proxy:

```bash
curl -I https://api.openai.com
```

### Additional workspaces

After the Compose stack has created the `codex-gpu:1.0` image and `proxy-net` network, create another isolated GPU workspace with a unique name and SSH port:

```bash
bash create_workspace.sh experiment-a 22003
ssh -p 22003 root@localhost
```

The workspace is stored at `$HOME/Workspaces/experiment-a` on the host, while `$HOME/Share` is shared across workspace containers.

### Common commands

```bash
# Follow service logs
docker compose logs -f

# Stop and remove the Compose containers
docker compose down

# Rebuild after changing a Dockerfile
docker compose up -d --build
```

### Ports and mounts

| Host | Container | Purpose |
| --- | --- | --- |
| `7890` | `mihomo_proxy:7890` | Mihomo mixed proxy port |
| `22001` | `mihomo_proxy:22` | SSH access to the proxy container |
| `22002` | `codex_gpu:22` | SSH access to the main GPU workspace |

| Host path | Container path | Purpose |
| --- | --- | --- |
| `./authorized_keys` | `/tmp/authorized_keys` | SSH public keys |
| `./mihomo_proxy/conf` | `/etc/mihomo` | Mihomo configuration |
| `$HOME/Workspaces/main` | `/root/workspace` | Persistent project files |
| `$HOME/Share` | `/root/share` | Shared files across workspaces |

### Security notes

- SSH password authentication is disabled; only public-key authentication is enabled.
- Review your firewall rules before exposing ports `7890`, `22001`, or `22002` beyond localhost.
- Keep Mihomo credentials, provider files, subscription URLs, and private keys out of version control.
- Review third-party installation scripts before running them in sensitive environments.

---

## 中文说明

### 项目简介

Mihomo Codex GPU Workspace 是一套可复现的远程开发环境，将以下组件组合在一起：

- 独立的 [Mihomo](https://github.com/MetaCubeX/mihomo) 代理容器；
- 支持 NVIDIA CUDA 与 cuDNN 的开发容器；
- 基于 SSH 密钥的远程访问；
- Miniconda、Git、Vim 与 tmux；
- 可供 Codex 及其他命令行工具按需启用的代理环境变量；
- 持久化的工作区与共享数据目录。

两个容器通过独立的 Docker 桥接网络通信。GPU 容器中已提供代理相关变量，但在交互式 Shell 中需要执行 `proxyon` 才会启用。

本项目由 **心之科学（杭州）有限责任公司** 开发和维护，我们为科学研究打造实用、便捷的 AI 工具。

### 架构

```text
宿主机
├── :22001 ──> mihomo_proxy:22
├── :7890  ──> mihomo_proxy:7890
└── :22002 ──> codex_gpu:22
                  │
                  └── proxy-net ──> mihomo_proxy:7890
```

### 前置条件

- Docker Engine 与 Docker Compose
- NVIDIA GPU 及兼容的驱动程序
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
- 一对 SSH 密钥
- 有效的 Mihomo 配置

### 快速开始

1. 克隆仓库并进入项目目录。

   ```bash
   git clone <repository-url>
   cd mihomo_codex
   ```

2. 将 SSH 公钥写入 `authorized_keys`。

   ```bash
   cp ~/.ssh/id_ed25519.pub authorized_keys
   ```

   可按每行一个密钥的格式添加多个公钥。请勿将私钥放入本仓库。

3. 将 Mihomo 配置保存为 `mihomo_proxy/conf/config.yaml`。

   请确保 Mihomo 监听 `7890` 端口，并允许来自 Docker 网络的连接。典型配置包含：

   ```yaml
   mixed-port: 7890
   allow-lan: true
   bind-address: "*"
   ```

   请在本地添加自己的代理提供商、节点、规则和凭据，不要提交密钥或订阅地址。

4. 创建 Docker Compose 需要挂载的宿主机目录。

   ```bash
   mkdir -p "$HOME/Workspaces/main" "$HOME/Share"
   ```

5. 构建并启动服务。

   ```bash
   docker compose up -d --build
   docker compose ps
   ```

6. 连接 GPU 工作区。

   ```bash
   ssh -p 22002 root@localhost
   ```

7. 验证 GPU，并按需安装 Codex。

   ```bash
   nvidia-smi
   bash /tmp/codex_install.sh
   ```

   如果安装后无法立即使用 `codex` 命令，请重新启动 Shell。

### 代理开关

在 GPU 容器中可使用以下 Shell 别名：

```bash
proxyon   # 启用 HTTP、HTTPS 与 SOCKS 代理变量
proxyoff  # 清除代理变量
```

启用代理后可测试连接：

```bash
curl -I https://api.openai.com
```

### 创建更多工作区

Compose 服务首次构建出 `codex-gpu:1.0` 镜像并创建 `proxy-net` 网络后，可以使用唯一的名称和 SSH 端口创建额外的独立 GPU 工作区：

```bash
bash create_workspace.sh experiment-a 22003
ssh -p 22003 root@localhost
```

该工作区在宿主机上保存于 `$HOME/Workspaces/experiment-a`，而 `$HOME/Share` 会在各工作区容器之间共享。

### 常用命令

```bash
# 持续查看服务日志
docker compose logs -f

# 停止并删除 Compose 容器
docker compose down

# Dockerfile 修改后重新构建
docker compose up -d --build
```

### 端口与挂载目录

| 宿主机 | 容器 | 用途 |
| --- | --- | --- |
| `7890` | `mihomo_proxy:7890` | Mihomo 混合代理端口 |
| `22001` | `mihomo_proxy:22` | 通过 SSH 访问代理容器 |
| `22002` | `codex_gpu:22` | 通过 SSH 访问主 GPU 工作区 |

| 宿主机路径 | 容器路径 | 用途 |
| --- | --- | --- |
| `./authorized_keys` | `/tmp/authorized_keys` | SSH 公钥 |
| `./mihomo_proxy/conf` | `/etc/mihomo` | Mihomo 配置 |
| `$HOME/Workspaces/main` | `/root/workspace` | 持久化项目文件 |
| `$HOME/Share` | `/root/share` | 各工作区共享文件 |

### 安全提示

- SSH 密码登录已禁用，仅允许公钥认证。
- 将 `7890`、`22001` 或 `22002` 端口暴露到本机以外的网络前，请检查防火墙规则。
- 不要将 Mihomo 凭据、代理提供商文件、订阅地址或私钥提交到版本控制。
- 在敏感环境中运行第三方安装脚本前，请先审查脚本内容。
