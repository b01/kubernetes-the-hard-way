# Bootstrapping the Kubernetes Control Plane

In this lab you will bootstrap the Kubernetes control plane. The following
components will be installed on the `controlplane` machine: Kubernetes API
Server, Scheduler, and Controller Manager.

## Prerequisites

Connect to the `jumpbox` and copy Kubernetes binaries and systemd unit files
to the `controlplane` machine:

```bash
scp \
  downloads/controller/kube-apiserver \
  downloads/controller/kube-controller-manager \
  downloads/controller/kube-scheduler \
  downloads/client/kubectl \
  units/kube-apiserver.service \
  units/kube-controller-manager.service \
  units/kube-scheduler.service \
  configs/kube-scheduler.yaml \
  configs/kube-apiserver-to-kubelet.yaml \
  vagrant@controlplane:~/
```

The commands in this lab must be run on the `controlplane` machine. Login to
the `controlplane` machine using the `ssh` command. Example:

```bash
ssh vagrant@controlplane
```

## Provision the Kubernetes Control Plane

Create the Kubernetes configuration directory:

```bash
sudo mkdir -p /etc/kubernetes/config
```

### Install the Kubernetes Controller Binaries

Install the Kubernetes binaries:

```bash
{
  sudo mv kube-apiserver \
    kube-controller-manager \
    kube-scheduler kubectl \
    /usr/local/bin/
}
```

### Configure the Kubernetes API Server

```bash
{
  sudo mkdir -p /var/lib/kubernetes/

  sudo mv ca.crt ca.key \
    kube-apiserver.key kube-apiserver.crt \
    service-accounts.key service-accounts.crt \
    encryption-config.yaml \
    /var/lib/kubernetes/
}
```

Create the `kube-apiserver.service` systemd unit file:

```bash
sudo mv kube-apiserver.service \
  /etc/systemd/system/kube-apiserver.service
```

### Configure the Kubernetes Controller Manager

Move the `kube-controller-manager` kubeconfig into place:

```bash
sudo mv kube-controller-manager.kubeconfig /var/lib/kubernetes/
```

Create the `kube-controller-manager.service` systemd unit file:

```bash
sudo mv kube-controller-manager.service /etc/systemd/system/
```

### Configure the Kubernetes Scheduler

Move the `kube-scheduler` kubeconfig into place:

```bash
sudo mv kube-scheduler.kubeconfig /var/lib/kubernetes/
```

Create the `kube-scheduler.yaml` configuration file:

```bash
sudo mv kube-scheduler.yaml /etc/kubernetes/config/
```

Create the `kube-scheduler.service` systemd unit file:

```bash
sudo mv kube-scheduler.service /etc/systemd/system/
```

### Start the Controller Services

```bash
{
  sudo systemctl daemon-reload

  sudo systemctl enable kube-apiserver \
    kube-controller-manager kube-scheduler

  sudo systemctl start kube-apiserver \
    kube-controller-manager kube-scheduler
}
```

> Allow up to 10 seconds for the Kubernetes API Server to fully initialize.

You can check if any of the control plane components are active using the `systemctl` command. For example, to check if the `kube-apiserver` fully initialized, and active, run the following command:

```bash
systemctl is-active kube-apiserver
```

For a more detailed status check, which includes additional process information and log messages, use the `systemctl status` command:

```bash
sudo systemctl status kube-apiserver
sudo systemctl status kube-controller-manager

sudo systemctl status kube-scheduler
```

If you run into any errors, or want to view the logs for any of the control plane components, use the `journalctl` command. For example, to view the logs for the `kube-apiserver` run the following command:

```bash
journalctl -u kube-apiserver
```

### Verification

At this point the Kubernetes control plane components should be up and running. Verify this using the `kubectl` command line tool:

```bash
kubectl cluster-info \
  --kubeconfig admin.kubeconfig
```

```text
Kubernetes control plane is running at https://127.0.0.1:6443
```

## RBAC for Kubelet Authorization

In this section you will configure RBAC permissions to allow the Kubernetes API Server to access the Kubelet API on each worker node. Access to the Kubelet API is required for retrieving metrics, logs, and executing commands in pods.

> This tutorial sets the Kubelet `--authorization-mode` flag to `Webhook`. Webhook mode uses the [SubjectAccessReview](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#checking-api-access) API to determine authorization.

The commands in this section will affect the entire cluster and only need to be run on the `controlplane` machine.

```bash
ssh root@controlplane
```

Create the `system:kube-apiserver-to-kubelet` [ClusterRole](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole) with permissions to access the Kubelet API and perform most common tasks associated with managing pods:

```bash
kubectl apply -f kube-apiserver-to-kubelet.yaml \
  --kubeconfig admin.kubeconfig
```

### Verification

At this point the Kubernetes control plane is up and running. Run the following commands from the `jumpbox` machine to verify it's working:

Make an HTTP request for the Kubernetes version info:

```bash
curl --cacert ca.crt \
  https://controlplane.kubernetes.local:6443/version
```

```text
{
  "major": "1",
  "minor": "32",
  "gitVersion": "v1.33.1",
  "gitCommit": "32cc146f75aad04beaaa245a7157eb35063a9f99",
  "gitTreeState": "clean",
  "buildDate": "2025-03-11T19:52:21Z",
  "goVersion": "go1.23.6",
  "compiler": "gc",
  "platform": "linux/arm64"
}
```

Next: [Bootstrapping the Kubernetes Worker Nodes](09-bootstrapping-kubernetes-workers.md)
