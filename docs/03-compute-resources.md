# Provisioning Compute Resources

Kubernetes requires a set of machines to host the Kubernetes control plane and
the worker nodes where containers are ultimately run. In this lab you will
ready the machines you have provisioned for setting up a Kubernetes cluster.

## Machine Database

This tutorial will leverage a text file, which will serve as a machine database,
to store the various machine attributes that will be used when setting up the
Kubernetes control plane and worker nodes. The following schema represents
entries in the machine database, one entry per line:

```text
IPV4_ADDRESS FQDN HOSTNAME POD_SUBNET
```

Each of the columns corresponds to a machine IP address `IPV4_ADDRESS`, fully
qualified domain name `FQDN`, host name `HOSTNAME`, and the IP subnet
`POD_SUBNET`. Kubernetes assigns one IP address per `pod` and the `POD_SUBNET`
represents the unique IP address range assigned to each machine in the cluster
for doing so.

Here is an example machine database similar to the one used when creating this
tutorial. Notice the IP addresses have been masked out. Your machines can be
assigned any IP address as long as each machine is reachable from each other
and the `jumpbox`.

```bash
cat machines.txt
```

```text
XXX.XXX.XXX.XXX controlplane.kubernetes.local controlplane
XXX.XXX.XXX.XXX node01.kubernetes.local node01 10.200.0.0/24
XXX.XXX.XXX.XXX node02.kubernetes.local node02 10.200.1.0/24
```

Now it's your turn to create a `machines.txt` file with the details for the
three machines you will be using to create your Kubernetes cluster. Use the
example machine database from above and add the details for your machines.
NOTE: Do NOT leave a newline at the end of the file, or you will get an error
when using it in the for loops.

### Generate and Distribute SSH Keys

In this section you will generate and distribute an SSH keypair to the
`controlplane`, `node01`, and `node02` machines, which will be used to run
commands on those machines throughout this tutorial. Run the following commands
from the `jumpbox` machine.

Generate a new SSH key:

```bash
ssh-keygen
```

```text
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
```

Copy the SSH public key to each machine:

```bash
while read IP FQDN HOST SUBNET; do
  ssh-copy-id vagrant@${IP}
done < machines.txt
```

Once each key is added, verify SSH public key access is working:

```bash
while read IP FQDN HOST SUBNET; do
  ssh -n vagrant@${IP} hostname
done < machines.txt
```

```text
controlplane
node01
node02
```

## Hostnames

In this section you will assign hostnames to the `controlplane`, `node01`,
and `node02` machines. The hostname will be used when executing commands from
the `jumpbox` to each machine. The hostname also plays a major role within the
cluster. Instead of Kubernetes clients using an IP address to issue commands to
the Kubernetes API server, those clients will use the `controlplane` hostname
instead. Hostnames are also used by each worker machine, `node01` and `node02`
when registering with a given Kubernetes cluster.

To configure the hostname for each machine, run the following commands on the
`jumpbox`.

Set the hostname on each machine listed in the `machines.txt` file:

```bash
while read IP FQDN HOST SUBNET; do
    CMD="sudo sed -i 's/^127.0.1.1.*/127.0.1.1\t${FQDN} ${HOST}/' /etc/hosts"
    ssh -n vagrant@${IP} "$CMD"
    ssh -n vagrant@${IP} sudo hostnamectl set-hostname ${HOST}
    ssh -n vagrant@${IP} sudo systemctl restart systemd-hostnamed
done < machines.txt
```

Verify the hostname is set on each machine:

```bash
while read IP FQDN HOST SUBNET; do
  ssh -n vagrant@${IP} hostname --fqdn
done < machines.txt
```

```text
controlplane.kubernetes.local
node01.kubernetes.local
node02.kubernetes.local
```

## Host Lookup Table

In this section you will generate a `hosts` file which will be appended to
`/etc/hosts` file on the `jumpbox` and to the `/etc/hosts` files on all three
cluster members used for this tutorial. This will allow each machine to be
reachable using a hostname such as `controlplane`, `node01`, or `node02`.

Create a new `hosts` file and add a header to identify the machines being added:

```bash
echo "" > hosts
echo "# Kubernetes The Hard Way" >> hosts
```

Generate a host entry for each machine in the `machines.txt` file and append it
to the `hosts` file:

```bash
while read IP FQDN HOST SUBNET; do
    ENTRY="${IP} ${FQDN} ${HOST}"
    echo $ENTRY >> hosts
done < machines.txt
```

Review the host entries in the `hosts` file:

```bash
cat hosts
```

```text

# Kubernetes The Hard Way
XXX.XXX.XXX.XXX controlplane.kubernetes.local server
XXX.XXX.XXX.XXX node01.kubernetes.local node01
XXX.XXX.XXX.XXX node02.kubernetes.local node02
```

## Adding `/etc/hosts` Entries To A Local Machine

In this section you will append the DNS entries from the `hosts` file to the
local `/etc/hosts` file on your `jumpbox` machine.

Append the DNS entries from `hosts` to `/etc/hosts`:

```bash
cat hosts | sudo tee -a /etc/hosts
```

Verify that the `/etc/hosts` file has been updated:

```bash
cat /etc/hosts
```

```text
127.0.0.1       localhost
127.0.1.1       jumpbox

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# Kubernetes The Hard Way
XXX.XXX.XXX.XXX controlplane.kubernetes.local server
XXX.XXX.XXX.XXX node01.kubernetes.local node01
XXX.XXX.XXX.XXX node02.kubernetes.local node02
```

At this point you should be able to SSH to each machine listed in the
`machines.txt` file using a hostname.

```bash
for host in controlplane node01 node02
   do ssh vagrant@${host} hostname
done
```

```text
controlplane
node01
node02
```

## Adding `/etc/hosts` Entries To The Remote Machines

In this section you will append the host entries from `hosts` to `/etc/hosts`
on each machine listed in the `machines.txt` text file.

Copy the `hosts` file to each machine and append the contents to `/etc/hosts`:

```bash
while read IP FQDN HOST SUBNET; do
  scp hosts vagrant@${HOST}:~/
  ssh -n \
    vagrant@${HOST} "cat hosts | sudo tee -a /etc/hosts"
done < machines.txt
```

At this point, hostnames can be used when connecting to machines from your
`jumpbox` machine, or any of the three machines in the Kubernetes cluster.
Instead of using IP addresses you can now connect to machines using a hostname
such as `controlplane`, `node01`, or `node02`.

Next: [Provisioning a CA and Generating TLS Certificates](04-certificate-authority.md)
