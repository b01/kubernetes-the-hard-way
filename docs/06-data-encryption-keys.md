# Generating the Data Encryption Config and Key

Kubernetes stores a variety of data including cluster state, application
configurations, and secrets. Kubernetes supports the ability to [encrypt]
cluster data at rest.

In this lab you will generate an encryption key and an [encryption config]
suitable for encrypting Kubernetes Secrets.

## The Encryption Key

Generate an encryption key:

```bash
export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
```

## The Encryption Config File

Create the `encryption-config.yaml` encryption config file:

```bash
envsubst < configs/encryption-config.yaml \
  > encryption-config.yaml
```

Copy the `encryption-config.yaml` encryption config file to each controller
instance:

```bash
scp encryption-config.yaml vagrant@controlplane:~/
```

Next: [Bootstrapping the etcd Cluster](07-bootstrapping-etcd.md)

---

[encrypt]: https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data
[encryption config]: https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#understanding-the-encryption-at-rest-configuration