#!/bin/bash

# Set your vSphere server details
source $PWD/.auth.conf
# Set the default datacenter and cluster
export GOVC_DATACENTER='cephqe-dc'
#export GOVC_CLUSTER='Cluster-2'
DATE="$(date '+%Y-%m-%d %H:%M:%S')"
# Function to establish connection with vc using govc
connect_vc()
{
        echo "[$DATE:INFO]:vCenter Connection Success"
        govc about
}
# Function to create vmfs datastore 
create_vm_on_NVMeTCP_VMFS6_Datastore()
{
        govc vm.clone -vm=rhel91-x64 -on=true -host='cephqe-virt11.lab.eng.blr.redhat.com' -ds=vmfsDatastore $1
        echo "[$DATE:INFO]: New VM Deployment on NVMeTCP VMFS6 Datastore :$1  Success"
}
create_vmfs_datastore()
{
        govc datastore.create -type vmfs -name vmfsDatastore -disk=$2 $1
        echo "[$DATE:INFO]:New VMFS6 Datastore Creation on ESXi Server:$1  Success"
}
add_host_into_cluster()
{
        govc cluster.add -cluster $1 -hostname $2 -username root -password VMware1! -noverify
        echo "[$DATE:INFO]:Add Host $1  Success"
}
# Function to create new cluster on vcenter
create_cluster() {
        govc cluster.create $1
        echo "[$DATE:INFO]:Cluster $1 Creation Success"
        add_host_into_cluster "$1" "$2"
}
list_nvmetcp_disks()
{
        echo "[$DATE:INFO]:List of NVMeTCP Disks on ESX $1"
        govc host.storage.info -host="$1" | grep eui*
}
# Function to list resources (VMs, hosts, datastores, clusters)
list_resources() {
    govc ls "/$GOVC_DATACENTER/$1"
}

connect
# List clusters
list_resources "cluster"
# List hosts
list_resources "host"
# List datastores
list_resources "datastore"
# Create New Cluster and Add Host into the cluster
create_cluster "Cluster-4" "argo030.ceph.redhat.com"

list_nvmetcp_disks "cephqe-virt11.lab.eng.blr.redhat.com"
#cat $PWD/.readme.txt | more

create_vmfs_datastore "cephqe-virt11.lab.eng.blr.redhat.com" "eui.01ffb9eaa33a47bbb1ad288e59a8a956"
create_vm_on_NVMeTCP_VMFS6_Datastore "newvmfs6vm_on_nvmetcpdisk"
~                                                                                                                                                                                             
~                                             
