# scripts

Lots of Misc shell scripts - some go back literally close to 25 years :)

cbr2cbz.nemo_action	- Add cbr2cbz.sh to the nemo file manager right click context. Store in .local/share/nemo/actions/ - modify with path to cbr2cbz.sh script

cbr2cbz.sh	- convert from a comic book rar archive to a comic book zip archive - suitable for ereaders like my wife's nook

cpacct.pl	- package and copy a cpanel account

doSed	- run sed on a file or group of files, text/exe mode

hb_encode	Encode a file using HandBrakeCLI


image_stacker.sh -- my attempt at trying to create a long exposure photo by
capturing X number of frames out of a video clip.  Still a work in progress.


#Linux KVM scripts
These scripts are all works in progress and I'm sure they can be greately
improved.

Base assumptions:

    - All vms live in $base_dir as defined in these scripts.
    - hyphens are used over underscores in all vm names, all disk names,
        hostnames, etc

clonevm - takes a template vm (e.g. rhel79, rhel84, rhel86) and generates a new
vm.  the new vm is generate with disks all encapsulated within a directory
under $base_dir. e.g. a new vm called "rhel79_apache" would have all of the
same disks defined as in the rhel79-template vm, but all files would be created
within $base_dir/rhel79-apache/

update-vm - the template vms are all pre-configured with the hosts SSH key, all
on the same IP address, so the update-vm script has 2 functions.
    - update-vm template newname newip
        in this call update-vm first calls clonevm with the template and new
        name. After cloning is complete, starts vm, adds to /etc/hosts on the
        hypervisor, renames the hostname, re-ips, reboots
    - update-vm cloned newname newip
        in this call update-vm assumes clonevm has already been run and newname
        already exists.  skips cloning starts vm, if ip is passed, adds to /etc/hosts on the
        hypervisor - if ip is not passed, assumes its already been manually
        added to /etc/hosts, renames the hostname, re-ips, reboots

start-ceph - used to control various groups of vms - normally ceph clusters
    - start - starts all vms
    - stop  - gives 'virsh stop' to gracefully shutdown
    - destroy - 'virsh destroy' - immediately powers down vm
    - ssh   - runs $3 command on all vms

