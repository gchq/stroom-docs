---
title: "NFS Installation and Configuration"
linkTitle: "NFS"
#weight:
date: 2021-07-12
tags: 
  - NFS
  - installation
description: >
  The following is a HOWTO to assist users in the installation and set up of NFS to support the sharing of directories in a two node Stroom cluster or add a new node to an existing cluster.
---

## Assumptions
The following assumptions are used in this document.
 - the user has reasonable RHEL/Centos System administration skills
 - installations are on Centos 7.3 minimal systems (fully patched)
 - the user is or has deployed the example two node Stroom cluster storage hierarchy described [here]({{< relref "InstallHowTo.md#storage-scenario" >}})
 - the configuration of this NFS is NOT secure. It is highly recommended to improve it's security in a production environment. This could include improved firewall configuration to limit NFS access, NFS4 with Kerberos etc.

## Installation of NFS software
We install NFS on each node, via
```bash
sudo yum -y install nfs-utils
```
and enable the relevant services, via
```base
sudo systemctl enable rpcbind
sudo systemctl enable nfs-server
sudo systemctl enable nfs-lock
sudo systemctl enable nfs-idmap
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start nfs-lock
sudo systemctl start nfs-idmap
```

## Configuration of NFS exports
We now export the node's /stroomdata directory (in case you want to share the working directories) by configuring /etc/exports. For simplicity sake, we will allow all nodes with the hostname nomenclature of stroomp*.strmdev00.org to mount the `/stroomdata` directory. This means the same configuration applies to all nodes.
```
# Share Stroom data directory
/stroomdata	stroomp*.strmdev00.org(rw,sync,no_root_squash)
```

This can be achieved with the following on both nodes
```bash
sudo su -c "printf '# Share Stroom data directory\n' >> /etc/exports"
sudo su -c "printf '/stroomdata\tstroomp*.strmdev00.org(rw,sync,no_root_squash)\n' >> /etc/exports"
```

On both nodes restart the NFS service to ensure the above export takes effect via
```bash
sudo systemctl restart nfs-server
```

So that our nodes can offer their filesystems, we need to enable NFS access on the firewall.
This is done via
```bash
sudo firewall-cmd --zone=public --add-service=nfs --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --zone=public --list-all
```

## Test Mounting
You should do test mounts on each node.
- Node: `stroomp00.strmdev00.org`

```bash
sudo mount -t nfs4 stroomp01.strmdev00.org:/stroomdata/stroom-data-p01 /stroomdata/stroom-data-p01
```

- Node: `stroomp01.strmdev00.org`

```bash
sudo mount -t nfs4 stroomp00.strmdev00.org:/stroomdata/stroom-data-p00 /stroomdata/stroom-data-p00
```

If you are concerned you can't see the mount with a `df` try a `df --type=nfs4 -a` or a `sudo df`. Irrespective, once the mounting works, make the mounts permanent by adding the following to each node's /etc/fstab file.
- Node: `stroomp00.strmdev00.org`

```
stroomp01.strmdev00.org:/stroomdata/stroom-data-p01 /stroomdata/stroom-data-p01 nfs4 soft,bg
```
achieved with

```bash
sudo su -c "printf 'stroomp01.strmdev00.org:/stroomdata/stroom-data-p01 /stroomdata/stroom-data-p01 nfs4 soft,bg\n' >> /etc/fstab"
```

- Node: `stroomp01.strmdev00.org`

```
stroomp00.strmdev00.org:/stroomdata/stroom-data-p00 /stroomdata/stroom-data-p00 nfs4 soft,bg
```
achieved with

```bash
sudo su -c "printf 'stroomp00.strmdev00.org:/stroomdata/stroom-data-p00 /stroomdata/stroom-data-p00 nfs4 soft,bg\n' >> /etc/fstab"
```
At this point reboot all processing nodes to ensure the directories mount automatically. You may need to give the nodes a minute to do this.

## Addition of another Node
If one needs to add another node to the cluster, lets say, `stroomp02.strmdev00.org`, on which `/stroomdata` follows the same storage hierarchy
as the existing nodes and all nodes have added mount points (directories) for this new node, you would take the following steps _in order_.

- Node: `stroomp02.strmdev00.org`

  * Install NFS software as [above]({{< relref "InstallNFSHowTo.md#installation-of-nfs-software" >}})
  * Configure the exports file as per

```bash
sudo su -c "printf '# Share Stroom data directory\n' >> /etc/exports"
sudo su -c "printf '/stroomdata\tstroomp*.strmdev00.org(rw,sync,no_root_squash)\n' >> /etc/exports"
```

  * Restart the NFS service and make the firewall enable NFS access as per
 
```bash
sudo systemctl restart nfs-server
sudo firewall-cmd --zone=public --add-service=nfs --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --zone=public --list-all
```

  * Test mount the existing node file systems

```bash
sudo mount -t nfs4 stroomp00.strmdev00.org:/stroomdata/stroom-data-p00 /stroomdata/stroom-data-p00
sudo mount -t nfs4 stroomp01.strmdev00.org:/stroomdata/stroom-data-p01 /stroomdata/stroom-data-p01
```

  * Once the test mounts work, we make them permanent by adding the following to the /etc/fstab file.

```
stroomp00.strmdev00.org:/home/stroomdata/stroom-data-p00 /home/stroomdata/stroom-data-p00 nfs4 soft,bg
stroomp01.strmdev00.org:/home/stroomdata/stroom-data-p01 /home/stroomdata/stroom-data-p01 nfs4 soft,bg
```
achieved with

```bash
sudo su -c "printf 'stroomp00.strmdev00.org:/stroomdata/stroom-data-p00 /stroomdata/stroom-data-p00 nfs4 soft,bg\n' >> /etc/fstab"
sudo su -c "printf 'stroomp01.strmdev00.org:/stroomdata/stroom-data-p01 /stroomdata/stroom-data-p01 nfs4 soft,bg\n' >> /etc/fstab"
```

- Node: `stroomp00.strmdev00.org` **and** `stroomp01.strmdev00.org`

  * Test mount the new node's filesystem as per

```bash
sudo mount -t nfs4 stroomp02.strmdev00.org:/stroomdata/stroom-data-p02 /stroomdata/stroom-data-p02
```

  * Once the test mount works, make the mount permanent by adding the following to the /etc/fstab file

```
stroomp02.strmdev00.org:/stroomdata/stroom-data-p02 /stroomdata/stroom-data-p02 nfs4 soft,bg
```
achieved with

```bash
sudo su -c "printf 'stroomp02.strmdev00.org:/stroomdata/stroom-data-p02 /stroomdata/stroom-data-p02 nfs4 soft,bg\n' >> /etc/fstab"
```

