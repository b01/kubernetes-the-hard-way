# Troubleshoot

This is a bit of a cheat sheet when you're not sure what to do. Its no guarantee
the answer is there tho.

* Vagrant list machine, but I don't see them in VirtualBox or HyperV. How can
  I remove them.
  * You'll want to try `vagrant global-status --prune`
* I don't see the nodes listed in the cluster after complete step 9. What do I
  do?
  * Go over all the steps in 9 again, but in reverse, and all the way back to
    step 1.
  * Focus on 1 node.
  * Make sure you didn't fiddle-finger and miss-type any of the values in the
    configs or commands.