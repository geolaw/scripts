#!/usr/local/bin/perl

$options = '';

if ($#ARGV >= 0) {
    if ($#ARGV >= 1) {
        $user = $ARGV[0];
        $override = $ARGV[1];
    } else {
        $user = $ARGV[0];
        $override = 0;
    }
}


print "Preparing cpanel sync for $user  \n";
$st = `grep ^$user: /etc/domainusers`;
if ( $st eq '') {
    print "$user not found in /etc/domainusers files, cannot continue\n";
    exit;
}

    $home1="/home/".$user;
    $home2="/home2/".$user;
    if ( -e $home1 ) {
        $cmd ="du -sk $home1";
        $home = $home1;
    } else  {
        if ( -e $home2 ) {
            $cmd="du -sk $home2";
        $home = $home2;
        } else {
            print "Unable to locate home directory - tried $home1 and $home2";
            exit;
        }
    }
    @parts = split(" ",`$cmd`);
    $size = $parts[0];
    if ($size > 1000000) {
        print "home directory is too large - will crate account with db, but will requires a manual sync\n";
        $options = ' --skiphomedir ';
    }
    $remote  = `ssh -p 2112 -i ~glaw/.ssh/id_dsa glaw\@web2.viewdm.com  -t "sudo grep $user /etc/domainusers"`;
    if ($remote ne '') {
      if ($override eq '') {

        print "$user already exists on remote system ? do rsync? ";
        $ans = <STDIN>;
        chomp($ans);
        if ($ans ne 'Y') {
            print "Exiting ...\n";
            exit;
        } else {
            $options = 'rsync';
        }
      } else {
                    $options = 'rsync';
    }

    } else {

	    print  "Packaging account for the move\n";
	    $status = system("/scripts/pkgacct $options $user");
	    if ($status != 0) {
	        print "Error in packaging account $user \n";
	        exit;
	    }
	    print "Copying package to web2.viewdm.com \n";
	    $status = system("scp -P 2112 -i ~glaw/.ssh/id_dsa /home2/cpmove-".$user.".tar.gz glaw\@web2.viewdm.com:/home/glaw");
	    print "scp status $status \n";
	
	    print "Restoring package on web2.viewdm.com \n";
	    $status = system ("ssh -p 2112  -i ~glaw/.ssh/id_dsa glaw\@web2.viewdm.com  -t \"sudo mv cpmove-$user.tar.gz /home;sudo /scripts/restorepkg $user\"");
   }

if ($override ne '') {
  $options = $override;
}

if ($options eq '') {
exit;
} else {
if ($options ne 'rsync')   {
    print "invalid option $options\n";
    exit;
}
print "here?";
#need to rsync
print "Enable shell on remote server ";
    $cmd = "ssh -p 2112  -i ~glaw/.ssh/id_dsa glaw\@web2.viewdm.com  -t \"sudo /usr/sbin/usermod -s /bin/bash $user\"";

    $status = system ($cmd);
    print "$cmd :: $status \n";
    $localhome = `/scripts/gethomedir $user`;
    chop($localhome);
    $remotehome = `ssh -p 2112  -i ~glaw/.ssh/id_dsa glaw\@web2.viewdm.com  -t \"sudo /scripts/gethomedir $user\"`;
    chomp($remotehome);
    chop($remotehome);
if ($options eq 'rsync') {
    $date = `date  "+%Y%m%d"`;
    chop($date);
    $cmd = "rsync  --delete --progress --exclude=.ssh  -az -e \"ssh  -p 2112  -i /home/glaw/.ssh/id_dsa -l $user \"   $localhome"."/ $user\@web2.viewdigitalmedia.com:".$remotehome."/";
} else {
    $cmd = "rsync  --progress  -az -e \"ssh  -p 2112  -i /home/glaw/.ssh/id_dsa -l $user \"   $localhome"."/public_html/ $user\@web2.viewdigitalmedia.com:".$remotehome."/public_html/";
}
print $cmd ."\n";
    $status = system ($cmd);

    $status = system ("ssh -p 2112  -i ~glaw/.ssh/id_dsa glaw\@web2.viewdm.com  -t \"sudo /usr/sbin/usermod -s /usr/local/cpanel/bin/noshell $user\"");
}
