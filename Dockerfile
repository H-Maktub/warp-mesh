FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

ARG APP_VERSION
RUN echo "Installing mypkg version: ${APP_VERSION}"

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    iproute2 \
    iptables \
    procps \
    grep \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg \
    | gpg --yes --dearmor -o /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg

RUN echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ bookworm main" \
    > /etc/apt/sources.list.d/cloudflare-client.list

RUN apt-get update && apt-get install -y cloudflare-warp=${APP_VERSION} \
    && rm -rf /var/lib/apt/lists/*
RUN apt clean
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD pgrep warp-svc >/dev/null && warp-cli --accept-tos status 2>/dev/null | grep -Eiq 'Connected|WARP is on|Success|connection: Connected' || exit 1

ENTRYPOINT ["/entrypoint.sh"]
