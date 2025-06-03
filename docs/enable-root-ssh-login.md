# Enable root Login

Initially the root account will be locked on all machines. You will need to
manually unlock the root account on each virtual machine.

You'll need to repeat these steps on each machine.

Login to the machine with the `vagrant` user:

`vagrant ssh@jumpbox`

Now set a password for the root account:

```shell
sudo passwd root
```

NOTE: You can choose password **vagrant** to keep it the same as the vagrant
user, and there will be only 1 password to remember.

You'll need to unlock the password of the named account. This option re-enables
a password by changing the password back to its previous value. In this case
it should be set to the password we just assigned.

```shell
sudo passwd -u root
```

Test that it works by running and entering the password you set:

```shell
su
```

## Configuring SSH Access

SSH will be used to configure the machines in the cluster. Verify that you have
`root` SSH access to each machine listed in your machine database. You may need
to enable root SSH access on each node by updating the sshd_config file and
restarting the SSH server.

### Enable root SSH Access

If `root` SSH access is enabled for each of your machines you can skip this
section.

By default, a new install may disable SSH access for the `root` user. This is
done for security reasons as the `root` user has total administrative control
of unix-like systems. If a weak password is used on a machine connected to the
internet, well, let's just say it's only a matter of time before your machine
belongs to someone else. As mentioned earlier, we are going to enable `root`
access over SSH in order to streamline the steps in this tutorial. Security is
a tradeoff, and in this case, we are optimizing for convenience. Log on to each
machine via SSH using your user account, then switch to the `root` user using
the `su` command:

```bash
su - root
```

Edit the `/etc/ssh/sshd_config` SSH daemon configuration file and set the
`PermitRootLogin` option to `yes`:

```bash
sed -i \
  's/^#*PermitRootLogin.*/PermitRootLogin yes/' \
  /etc/ssh/sshd_config
```

Restart the `sshd` SSH server to pick up the updated configuration file:

```bash
systemctl restart sshd
```
