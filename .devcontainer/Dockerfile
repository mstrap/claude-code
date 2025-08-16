FROM node:20

ARG TZ
ENV TZ="$TZ"

ARG CLAUDE_CODE_VERSION=latest

# Install basic development tools
RUN apt-get update && apt-get install -y --no-install-recommends \
  less \
  git \
  procps \
  fzf \
  man-db \
  unzip \
  gnupg2 \
  iptables \
  ipset \
  iproute2 \
  dnsutils \
  jq \
  nano \
  vim \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ARG USERNAME=node

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Create workspace and config directories and set permissions
RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# Set up non-root user
USER node

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Use bash as the default shell and editor
ENV SHELL=/bin/bash
ENV EDITOR=nano
ENV VISUAL=nano

# Install Claude
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Copy firewall and entrypoint scripts, expose claude binary
COPY init-firewall.sh docker-entrypoint.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/init-firewall.sh /usr/local/bin/docker-entrypoint.sh && \
  ln -sf /usr/local/share/npm-global/bin/claude /usr/local/bin/claude

# Disable root access by removing setuid from su and locking root
RUN chmod u-s /usr/bin/su && \
    passwd -l root && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Run firewall on container start then drop to node
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]
