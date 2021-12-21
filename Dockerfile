FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    build-essential \
    ca-certificates \
    curl \
    dnsutils \
    git \
    iputils-ping \
    jq \
    libcurl4 \
    libicu66 \
    libunwind8 \
    libssl1.1 \
    netcat \
    gpg-agent \
    software-properties-common \
    unzip \
    wget \
    zip

# yq is a jq-like processor for YAML
RUN wget https://github.com/mikefarah/yq/releases/download/v4.2.0/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

# Node and yarn
RUN curl -sSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sSL https://deb.nodesource.com/setup_12.x | bash -

RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    yarn \
    python3-pip

# Cypress dependencies
RUN apt-get install -y --no-install-recommends \
    libgtk2.0-0 \
    libgtk-3-0 \
    libgbm-dev \
    libnotify-dev \
    libgconf-2-4 \
    libnss3 \
    libxss1 \
    libasound2 \
    libxtst6 \
    xauth \
    xvfb

# AWS CLI
RUN curl -L https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.1.37.zip -o awscliv2.zip
RUN unzip -q awscliv2.zip
RUN ./aws/install && rm -rf ./aws

# .NET SDK + PowerShell Core
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb

RUN apt-get update && apt-get install -y --no-install-recommends \
    powershell \
    dotnet-sdk-2.1 \
    dotnet-sdk-3.1 \
    dotnet-sdk-5.0 \
    dotnet-sdk-6.0

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

SHELL ["/usr/bin/pwsh", "-c", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Install-Module -Name AWSPowerShell.NetCore -RequiredVersion 4.1.15.0 -Force
RUN Install-Module -Name AzureRM.NetCore -RequiredVersion 0.13.2 -Force
SHELL ["/bin/sh", "-c"]

RUN mkdir -p ${HOME}/.config/powershell
RUN echo "Import-Module AWSPowerShell.NetCore" > ${HOME}/.config/powershell/Microsoft.PowerShell_profile.ps1

# Environment variables, so that Azure Devops can pick up the binaries as agent capabilities
ENV yarn=/usr/bin/yarn
ENV aws=/usr/local/bin/aws
ENV azurecli=/usr/bin/az

# See versions https://github.com/Microsoft/azure-pipelines-agent/releases
ARG TARGETARCH=amd64
ARG AGENT_VERSION=2.196.2

WORKDIR /azp
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz; \
    else \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-${TARGETARCH}-${AGENT_VERSION}.tar.gz; \
    fi; \
    curl -LsS "$AZP_AGENTPACKAGE_URL" | tar -xz

COPY ./start.sh .
RUN chmod +x start.sh
ENTRYPOINT ["./start.sh"]

#CMD ["/bin/bash"]

