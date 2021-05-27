# Linux build agent for Azure Devops

This image contains all the necessary tooling to configure a build agent for Azure Devops


## Prerequisites
- Docker installed and configured on the host machine
- A PAT (Personal Access Token) for the corresponding [Azure Devops](https://docs.microsoft.com/en-us/vsts/accounts/use-personal-access-tokens-to-authenticate)

## Build

```
docker build -t azure-devops-ubuntu-agent .
```

## Run

`EdinburghOffice` is the default pool that we are currently using for generic linux agents, change if required.

### Using an Android emulator
`--device /dev/kvm` # allow access to hardware virtualisation

### Using an Android device over USB
`-v /dev/bus/usb:/dev/bus/usb` # allow access to USB interface

```
docker run -d --restart unless-stopped --privileged -v /dev/bus/usb:/dev/bus/usb --device /dev/kvm -e AZP_URL=https://vehnet.visualstudio.com -e AZP_TOKEN=XXXXXX -e AZP_POOL=EdinburghOffice azure-devops-ubuntu-agent

```
