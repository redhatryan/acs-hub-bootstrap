### Introduction

This repository is used to bootstrap the RHACS Hub cluster as well as hold the ACS configuration
I use in my homelab environment. It is referenced by the [cluster-config](https://github.com/redhatryan/cluster-config) repo for the `local.acs` cluster's ACS applications (hub and policies).

From the perspective of bootstrapping the Hub there are a couple of different ways to go. You could
manually install OpenShift GitOps and have it bootstrap everything on the Hub, but the below workflow was created for consistency as my homelab scales. To run the workloads I'm needing for ACS, I'm unable to concurrently run OpenShift GitOps and ACS on my Intel NUC due to compute limitations, so I use a GitOps Cluster configured on the RHACM hub to leverage the ArgoCD instance installed there.

### Steps

1. Import ACS cluster to ACM hub
2. Log into ACM hub and run `bootstrap-acs-remote.sh` 
3. Log into ACS hub and run `bootstrap-acs-local.sh`

### Bootstrap Process - ACS Remote

The bootstrap process, encapsulated in the `bootstrap-acs-remote.sh` script, deploys RHACM policies to:

1. Create the ManagedCluster ClusterRole
2. Create the ManagedCluster
3. Create the ManagedClusterSet
4. Create the ManagedClusterSetBinding
5. Create the GitOpsCluster
6. Create an ArgoCD AppProject and Application to bootstrap the cluster-configuration from the [cluster-config](https://github.com/redhatryan/cluster-config) repo
7. Create the ESO ClusterSecretStore for ExternalSecrets using Doppler
4. Label the Hub cluster, `acs-hub`, with the label `acs-gitops=local.acs`. This triggers the
GitOps policy we deployed in step #6 to deploy the bootstrap application pointing to the repo and path needed for this cluster, i.e.
`local.acs`

### Bootstrap Process - ACS Local

The bootstrap process, encapsulated in the `bootstrap-acs-local.sh` script, is as follows:

1. Locally, on the newly provisioned ACS server, install secrets needed for bootstrapping ACS from the ACM hub after running the `bootstrap-acs-remote.sh` script.


At this point the GitOps operator on the RHACM hub deploys everything the ACS Hub cluster requires including storage, operators, etc
as well as other ACS components. In particular, the components that the script deployed (Hub + Policies) have
Argo applications that will take over managing these.

With the script bootstrapping the ACS Hub because a one command affair. Once the command completes successfully, you can walk away for 20-30 minutes while everything gets sorted out.

### Side-note on LVM Operator

If you are running a SNO cluster like I am and using the LVM Operator make sure that whatever device you are using for storage with it is free. For example, if you are doing a reinstall of the hub (or other cluster), after the cluster is provisioned but before you provision Day 2 ops ssh to the cluster and run `lsblk` to make sure the device is empty with no partitions.

NOTE: There must be no activity on the disk while the next steps are performed. Disable LVM via GitOps if currently enabled, and then proceed with the below.

To do this, run `dd if=/dev/zero of=/dev/sda bs=512 count=1` from the node (chroot /host). If LVM still doesn't detect disks, manually create the `system.devices` file at `/etc/lvm/devices` by adding the drive `lvmdevices --adddev /dev/sda`. Delete LVMCluster and the vg-manager and topolvm-node pods.

Ref: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_and_managing_logical_volumes/limiting-lvm-device-visibility-and-usage_configuring-and-managing-logical-volumes

https://man7.org/linux/man-pages/man8/lvmdevices.8.html