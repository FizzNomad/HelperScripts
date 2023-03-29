## create_nfs_share.sh
- Applying permissions is not very intuitive and needs work.
- script can check if a directory already exists and asks if you want to use it but it fails to update the permissions and apply them to /etc/exports

- need to add functionality to mount the share:
  ```
  mkdir ~/target_nfs
  mount x.x.x.x:/home/fizz/special_share ~/target_nfs
  tree ~/target_nfs
  ```
  
  ### Use
  The NFS share (special_share) from target (x.x.x.x) has been mounted locally to the system in the mount point target_nfs 
  over the network and I can now view the contents just as if I was on the target system.
