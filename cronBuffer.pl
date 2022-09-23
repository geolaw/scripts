#!/usr/bin/perl
if ($#ARGV > 0) {
  if ($#ARGV == 1) {
    $to = $ARGV[0];
    $subject = $ARGV[1];
$subject =~ s/_/ /g;
}
}
while (<STDIN>) {
  $content .= $_;
}
$from = 'AWS <server@'.`hostname`;
chomp($from);
$from.=">";

sub sendmail {
    ($msg,$from,$to,$subject,$bcc,$filepath,$filename) = @_;
    use MIME::Lite;
    #mime::Lite->send("sendmail", "/usr/sbin/sendmail -t -oi -oem");
    $yoursmtpserver = "/usr/lib/sendmail -t";
    #$subject .= "to=$to";
    if ($bcc ne "") {
        $mailer = MIME::Lite->new(From=>$from,
                              To=>$to,
                              Subject=>$subject,
                              Type=>'multipart/mixed');

    } else {
        $mailer = MIME::Lite->new(From=>$from,
                              To=>$to,
                              Subject=>$subject,
                              Type=>'multipart/mixed');
    }
    $mailer->attach( Type=>'text/plain',
                     Data=> $msg);
    if ($filepath ne "") {
        (undef,$type) = split(/\./,$filename);
        $mailer->attach(Type=>"application/$type",
                        Path=>"$filepath",
                        Filename=>"$filename",
                        Dispostion=>'attachment');
    }

    if (! $mailer->send('sendmail', $yoursmtpserver)) {
        return(0);
    } else {
        return(1);
    }
}


if ($content ne '') {

    sendmail("$content",$from,$to, $subject);
}
