#!/bin/bash

# Enable root account login

# If sudo with the default vagrant SSH user is acceptable, then we may not do
# this and just update the documentation to use the vagrant user and sudo before
# commands.

# Set the root user password
echo -e "vagrant\nvagrant" | passwd root

# unlock the root user
passwd -u root

# Enable root SSH login
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

systemctl restart sshd

echo "root account setup script done"