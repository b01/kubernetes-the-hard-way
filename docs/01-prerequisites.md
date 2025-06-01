# Prerequisites

In this lab you will review the machine requirements necessary to follow this
tutorial.

## Virtual or Physical Machines

This tutorial requires four (4) virtual or physical ARM64 or AMD64 machines
running Debian 12 (bookworm). The following table lists the four machines and
their CPU, memory, and storage requirements.

| Name         | Description            | CPU | RAM   | Storage |
|--------------|------------------------|-----|-------|---------|
| jumpbox      | Administration host    | 1   | 512MB | 10GB    |
| controlplane | Kubernetes server      | 1   | 2GB   | 20GB    |
| node01       | Kubernetes worker node | 1   | 2GB   | 20GB    |
| node02       | Kubernetes worker node | 1   | 2GB   | 20GB    |

How you provision the machines is up to you, the only requirement is that each
machine meet the above system requirements including the machine specs and OS
version.

We provide [virtual machines] that act as a blank environment. It can be spun
up locally with Vagrant and either VirtualBox or HyperV.

Once you have all four machines provisioned, verify the OS requirements by
viewing the `/etc/os-release` file:

```bash
cat /etc/os-release
```

You should see something similar to the following output:

```text
PRETTY_NAME="Ubuntu 22.04.5 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04.5 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
```

Next: [setting-up-the-jumpbox](02-jumpbox.md)

---

[virtual machines]: /virtual-machines/README.md
