# Example of using clonevm, update-ceph and start-ceph

These are scripts I wrote to speed up deployment and management of kvm
virtualized ceph clusters based off template vms

## template vms
- all configured on the same IP for update-ceph to be able to access
- configured with ssh key from the host machine
- configured with ssh key from itself
- basic format :   rhel91-template  : rhel 9.1
                   rhel86-template  : rhel 8.6
- registered and up to date , may need to be re-registered when used.
- rhel9 based - root ssh enabled
- ssh config - wild cards rhel91-* so user=root

## Clone my rhel91-template out to 5 cluster nodes :
```
$ for i in rhel91-rhcs53-admin rhel91-rhcs53-node01 rhel91-rhcs53-node02 rhel91-rhcs53-node03 rhel91-rhcs53-proxy; do
    clonevm rhel91-template  $i
done
```

## host /etc/hosts
```
grep rhel91-rhcs53 /etc/hosts
192.168.56.20 rhel91-rhcs53-admin
192.168.56.21 rhel91-rhcs53-node01
192.168.56.22 rhel91-rhcs53-node02
192.168.56.23 rhel91-rhcs53-node03
192.168.56.24 rhel91-rhcs53-proxy
```

## update-ceph example
```
$ update-ceph cloned rhel91-rhcs53-admin
skipping the cloning, using already cloned vm rhel91-rhcs53-admin
Starting clone rhel91-rhcs53-admin
Domain 'rhel91-rhcs53-admin' started

/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/glaw/.ssh/id_rsa.pub"

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh -o 'StrictHostKeyChecking=no' 'ceph-template'"
and check to make sure that only the key(s) you wanted were added.

Changing hostname to rhel91-rhcs53-admin
rhel91-template
rhel91-rhcs53-admin
skipping adding rhel91-rhcs53-admin to hosts
changing IP to 192.168.56.20
Connection to ceph-template closed by remote host.

$ ping rhel91-rhcs53-admin
PING rhel91-rhcs53-admin (192.168.56.20) 56(84) bytes of data.
64 bytes from rhel91-rhcs53-admin (192.168.56.20): icmp_seq=1 ttl=64 time=0.144 ms

$ ssh rhel91-rhcs53-admin hostname
rhel91-rhcs53-admin
$ ssh rhel91-rhcs53-admin id
uid=0(root) gid=0(root) groups=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```


 virsh list
 Id   Name                   State
--------------------------------------
 1    rhel91-rhcs53-admin    running
 2    rhel91-rhcs53-node01   running
 3    rhel91-rhcs53-node02   running
 4    rhel91-rhcs53-node03   running
 5    rhel91-rhcs53-proxy    running

## start-ceph examples

 start-ceph ssh rhel91-rhcs53 "subscription-manager repos --enable=rhceph-5-tools-for-rhel-8-x86_64-rpms"

## ceph install
ssh to node01 :
[root@rhel91-rhcs53-node01 ~]$ cephadm bootstrap --cluster-network 192.168.56.0/24 --mon-ip 192.168.56.21 --registry-url registry.redhat.io --registry-username glaw@redhat.com --registry-password 1210W\!llis --yes-i-know --skip-mon-network

Don't forget to adding public_network before adding any additional monitors
[ceph: root@rhel91-rhcs53-node01 /]# ceph config set mon public_network 192.168.56.0/24
# ceph orch daemon add mon "rhel91-rhcs53-node02 rhel91-rhcs53-node03 rhel91-rhcs53-admin rhel91-rhcs53-proxy"

## Additional ideas
- based on the destination vm name in clonevm - when running update-ceph, grab the matchine string from host's /etc/hosts to pre-populate the vms /etc/hosts file

## clone existing cluster
e.g. take existing rhel91-rhcs53 cluster, make a clone in the rhcs53-6up sub
directory for upgrade testing

1847  clonevm rhel91-rhcs53-node01 rhel91-rhcs53u-node01 rhcs53-6up
 1848  vi ~/bin/clonevm
 1849  clonevm rhel91-rhcs53-node01 rhel91-rhcs53u-node01 rhcs53-6up
 1850  clonevm rhel91-rhcs53-node02 rhel91-rhcs53u-node02 rhcs53-6up
 1851  clonevm rhel91-rhcs53-node03 rhel91-rhcs53u-node03 rhcs53-6up
 1852  clonevm rhel91-rhcs53-proxy rhel91-rhcs53u-proxy rhcs53-6up

NOTE! - need to be careful doing this as the clone cluster will also have all
of the same IP addresses -- cannot run both clusters at the same time

reuse same ips in /etc/hosts:

192.168.56.20 rhel91-rhcs53-admin  rhel91-rhcs53u-admin
192.168.56.21 rhel91-rhcs53-node01 rhel91-rhcs53u-node01
192.168.56.22 rhel91-rhcs53-node02 rhel91-rhcs53u-node01
192.168.56.23 rhel91-rhcs53-node03 rhel91-rhcs53u-node01
192.168.56.24 rhel91-rhcs53-proxy rhel91-rhcs53u-proxy

 within the cluster, all of the original vm names continue to work

