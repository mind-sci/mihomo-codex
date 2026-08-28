alias proxyon='export HTTP_PROXY=${MIHOMO_HTTP_PROXY}; \
export HTTPS_PROXY=${MIHOMO_HTTPS_PROXY}; \
export ALL_PROXY=${MIHOMO_ALL_PROXY}; \
export NO_PROXY=${MIHOMO_NO_PROXY}; \
echo Proxy enabled'

alias proxyoff='unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY; echo Proxy disabled'