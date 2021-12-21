# Linux build agent for Azure Devops

This image contains all the necessary tooling to configure a build agent for Azure Devops

Based on [these instructions](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops), but adapted to run on Ubuntu 20.04 with additional tools

## Prerequisites
- Docker installed and configured on the host machine
- A PAT (Personal Access Token) for the corresponding [Azure Devops](https://docs.microsoft.com/en-us/vsts/accounts/use-personal-access-tokens-to-authenticate)

## Build

```
docker build -t azure-devops-ubuntu-agent .

```
## Run

`EdinburghOffice` is the default pool that we are currently using for generic linux agents, change if required.

docker run -d -e AZP_URL=https://vehnet.visualstudio.com -e AZP_TOKEN=<PAT token> -e AZP_POOL=EdinburghOffice azure-devops-docker-agent

### Using an Android emulator
`--device /dev/kvm` # allow access to hardware virtualisation

### Using an Android device over USB
`-v /dev/bus/usb:/dev/bus/usb` # allow access to USB interface

```
docker run -d --restart unless-stopped --privileged -v /dev/bus/usb:/dev/bus/usb --device /dev/kvm -e AZP_URL=https://vehnet.visualstudio.com -e AZP_TOKEN=XXXXXX -e AZP_POOL=EdinburghOffice azure-devops-ubuntu-agent

```
