### omg_all_logs

The openshift cli 'oc' allows you to interactively get logs from all containers
within a pod.

$ oc logs pod/rook-ceph-osd-7-7ccdbcd4f4-nxfv5 --all-containers

omg lacks the --all-containers option, but 'omg_all_logs' extends omg to allow
all containers.  Updated to also capture the previous log if it exists.

#### Usage :
```
$ omg_all_logs
Usage: path/to/omg_all_logs -p _pattern_ -o _output_dir_
will get all container logs for pod matching _pattern_
Output is to stdout unless -o is specified

skips pods matching replicaset and deployment as omg is unable to extract those logs
```

#### Example with osd-7 and output to cephout directory
```
$ omg_all_logs -p osd-7 -o cephout

Will capture all oc logs for pods :
	pod/rook-ceph-osd-7-7ccdbcd4f4-nxfv5
Continue? any key or ctrl-c to quit


Capturing events for pod pod/rook-ceph-osd-7-7ccdbcd4f4-nxfv5 to cephout/pod_rook-ceph-osd-7-7ccdbcd4f4-nxfv5_events
Capturing logs from pod pod/rook-ceph-osd-7-7ccdbcd4f4-nxfv5 container blkdevmapper to cephout/pod_rook-ceph-osd-7-7ccdbcd4f4-nxfv5_blkdevmapper
Capturing logs from pod pod/rook-ceph-osd-7-7ccdbcd4f4-nxfv5 container log-collector to cephout/pod_rook-ceph-osd-7-7ccdbcd4f4-nxfv5_log-collector
Capturing logs from pod pod/rook-ceph-osd-7-7ccdbcd4f4-nxfv5 container expand-bluefs to cephout/pod_rook-ceph-osd-7-7ccdbcd4f4-nxfv5_expand-bluefs
Capturing logs from pod pod/rook-ceph-osd-7-7ccdbcd4f4-nxfv5 container osd to cephout/pod_rook-ceph-osd-7-7ccdbcd4f4-nxfv5_osd
Capturing logs from pod pod/rook-ceph-osd-7-7ccdbcd4f4-nxfv5 container chown-container-data-dir to cephout/pod_rook-ceph-osd-7-7ccdbcd4f4-nxfv5_chown-container-data-dir
```
#### Example files in output directory
```
$ ls -la cephout/
total 386
drwx--S--- 2 geolaw   swsupt  4096 Apr 14 18:55 .
drwxrwsr-x 4 ecuunpck swsupt  4096 Apr 14 18:55 ..
-rw------- 1 geolaw   swsupt  1522 Apr 14 18:55 pod_rook-ceph-osd-7-7ccdbcd4f4-nxfv5_blkdevmapper
-rw------- 1 geolaw   swsupt  9506 Apr 14 18:55 pod_rook-ceph-osd-7-7ccdbcd4f4-nxfv5_chown-container-data-dir
-rw------- 1 geolaw   swsupt  1019 Apr 14 18:55 pod_rook-ceph-osd-7-7ccdbcd4f4-nxfv5_events
-rw------- 1 geolaw   swsupt   528 Apr 14 18:55 pod_rook-ceph-osd-7-7ccdbcd4f4-nxfv5_expand-bluefs
-rw------- 1 geolaw   swsupt 16584 Apr 14 18:55 pod_rook-ceph-osd-7-7ccdbcd4f4-nxfv5_log-collector
-rw------- 1 geolaw   swsupt   900 Apr 14 18:55 pod_rook-ceph-osd-7-7ccdbcd4f4-nxfv5_osd

