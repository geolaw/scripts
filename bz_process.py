#!/usr/bin/python3

# first pass python script
# takes a csv exported from a bugzilla instance and generates a new csv  formatted differently
# written based on RHCS Ceph bugzillas

import csv,re,sys
import_file=sys.argv[1]
ceph_vers=sys.argv[2]
output_file="processed_"+import_file
output_handle=open(output_file,'wt');
bz_base='https://bugzilla.redhat.com/show_bug.cgi?id='
fieldnames=['CVE','Bugzilla','Name','Affected Component','Date','Serverity','Ceph Version']
writer = csv.DictWriter(output_handle,fieldnames=fieldnames,delimiter='\t',quotechar='"', quoting=csv.QUOTE_MINIMAL)
writer.writeheader()

with open(import_file,newline='') as csvfile:
    bzreader=csv.DictReader(csvfile,delimiter=',',quotechar='"')
    # read in a row from the source file
    # "ID","Product","Component","Assignee","Status","Summary","Changed","Severity","Priority"
    for row in bzreader:
        # processing :
        # read the summary, it may have one or more CVE tags which
        # we need to turn each CVE into a new row in the output file
        # CVE-2021-3114 CVE-2021-3115 golang-github-prometheus-node_exporter: various flaws [ceph-3-default]
        # following the CVE will be one or more components, each followed by a :
        # CVE-2020-7793 grafana: nodejs-ua-parser-js: ReDoS in multiple regexes [ceph-3-default]
        try:
            cves=re.findall(r'CVE-\d+-\d+',row['Summary'],flags=re.A);
            comps=re.findall(r'\S+:',row['Summary']);
            cve_date=row['Changed']
            sev=row['Severity']
            summary=row['Summary'].rpartition(':')[-1]
            for cve in cves:
                for comp in comps:
                    out={
                            "CVE":cve,
                            "Bugzilla":bz_base+row['ID'],
                            "Name":summary,
                            "Affected Component":comp,
                            "Date":cve_date,
                            "Serverity":sev,
                            "Ceph Version":ceph_vers
                        }
                    writer.writerow(out)
        except AttributeError:
            pass

