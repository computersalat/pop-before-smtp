# This config file is a perl library that can override various aspects of the
# pop-before-smtp script's setup.  Install it as /etc/pop-before-smtp-conf.pl

# There's quite a bit of sample stuff after the options, so you probably don't
# need to read through all of this.  If you're using Postfix and UW POP/IMAP,
# you can likely just use the default setup without any changes.  The most
# common changes needed are to pick the right $pat variable for your POP/IMAP
# software, ensure that the maillog name is right, and perhaps uncomment a
# section with the support for a different SMTP (other than Postfix).  See the
# contrib/README.QUICKSTART file for step-by-step instructions on how to
# install and test your setup.

use vars qw(
    $pat $write $flock $debug $reprocess $grace $logto %file_tail
    @mynets %db $dbfile $dbvalue
    $mynet_func $tie_func $sync_func $flock_func $log_func
);

#
# Override the default options here (or use the command-line options):
#

# Clear to avoid our exclusive file locking when updating the DB.
#$flock = 0;

# Set $debug to output some extra log messages (if logging is enabled).
#$debug = 1;
#$logto = '-'; # Log to stdout.
#$logto = '/var/log/pop-before-smtp';

# Override the DB hash file we will create/update (".db" gets appended).
#$dbfile = '/etc/postfix/pop-before-smtp';

# Override the value that gets put into the DB hash.
#$dbvalue = 'ok';

# A 30-minute grace period before the IP address is expired.
#$grace = 30*60;

# Set the log file we will watch for pop3d/imapd records.
#$file_tail{'name'} = '/var/log/maillog';

# ... or we'll try to figure it out for you.
if (!-f $file_tail{'name'}) {
    foreach (qw( /var/log/mail/info /var/log/mail.log
		 /var/log/messages /var/adm/messages )) {
	if (-f $_) {
	    $file_tail{'name'} = $_;
	    last;
	}
    }
}

# If you need to define a custom PATH (for instance, if you're using Postfix
# and postconf is someplace wierd), uncomment and customize this.
#$ENV{'PATH'} = '/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/sbin:/usr/local/bin';

# These parameters control how closely the watcher tries to follow the
# logfile, which affects how much resources it consumes, and how quickly
# people can smtp after they have popped.  These values are documented in
# the File::Tail pod (run "perldoc File::Tail" to find out details).
# These commented-out values are the ones Daniel Roesen prefers.

#$file_tail{'maxinterval'} = 2;
#$file_tail{'interval'} = 1;
#$file_tail{'adjustafter'} = 3;
#$file_tail{'resetafter'} = 30;
#$file_tail{'tail'} = -1;

=pod #============================= syslog ===========================START=
# If you want to output a log file of what pop-before-smtp is doing, you have
# a few choices: either set $logto above, comment-out the =pod line above to
# use this syslog section, or put a reference to your own custom logging
# function into $log_func.

use Sys::Syslog;
openlog('pop-before-smtp', 'pid', 'mail');
$log_func = \&syslog;
=cut #============================= syslog =============================END=

############################ START OF PATTERNS #############################
#
# Pick one of these values for the $pat variable OR define a subroutine
# named "custom_match" to handle a more complex match scenario (there's
# an example below).  Feel free to delete all the stuff you don't need.
#
############################ START OF PATTERNS #############################

# For UW ipop3d/imapd and their secure versions. This is the DEFAULT.
#$pat = '^(... .. ..:..:..) \S+ (?:ipop3s?d|imaps?d)\[\d+\]: ' .
#    '(?:Login|Authenticated|Auth) user=\S+ ' .
#    'host=(?:\S+ )?\[(\d+\.\d+\.\d+\.\d+)\](?: nmsgs=\d+/\d+)?$';

# For GNU pop3d
#$pat = '^(... .. ..:..:..) \S+ gnu-pop3d\[\d+\]: ' .
#    'User .* logged in with mailbox .* from (\d+\.\d+\.\d+\.\d+)$';

# There are many, many different logfile formats emitted by various
# qpoppers. Here's an attempt to match any of them, but, for all
# I know, it might also match failed logins or something else.
#$pat = '^(... .. ..:..:..) \S+ q?popper\S+\[\d+\]: ' .
#    '.*\s(\d+\.\d+\.\d+\.\d+)$';

# For Cyrus, Kenn Martin <kmartin@infoteam.com>, with tweak
# from William Yodlowsky for IP addrs that don't resolve:
#$pat = '^(... .. ..:..:..) \S+ (?:pop3d|imapd)\[\d+\]: ' .
#    'login: \S*\[(\d+\.\d+\.\d+\.\d+)\] \S+ \S+';

# For Courier-POP3 and Courier-IMAP:
#$pat = '^(... .. ..:..:..) \S+ (?:courier)?(?:pop3|imap)(?:login|d|d-ssl): ' .
#    'LOGIN, user=\S+, ip=\[[:f]*(\d+\.\d+\.\d+\.\d+)\]$';

# For qmail's pop3d:
#$pat = '^(... .. ..:..:..) \S+ vpopmail\[\d+\]: ' .
#    'vchkpw: login \[\S+\] from (\d+\.\d+\.\d+\.\d+)$';

# For Qpopper POP/APOP Server
#$pat = '^(... .. ..:..:..) \S+ qpopper\[\d+\]: Stats: \S+ ' .
#    '(?:\d+ ){4}(\d+\.\d+\.\d+\.\d+)';

# Alex Burke's popper install
#$pat = '^(... .. ..:..:..) \S+ q?popper\[\d+\]: Stats: \S+ ' .
#    '(?:\d+ ){4}(?:\S+ )?(\d+\.\d+\.\d+\.\d+)$';

# Chris D.Halverson's pattern for Qpopper 3.0b29 on Solaris 2.6
#$pat = '^(\w{3} \w{3} \d\d \d\d:\d\d:\d\d \d{4}) \[\d+\] ' .
#    ' Stats:\s+\w+ \d \d \d \d [\w\.]+ (\d+\.\d+\.\d+\.\d+)';

# Nick Bauer <nickb@inc.net> has something completely different as
# a qpopper logfile format
#$pat = '^(... .. ..:..:..) \S+ qpopper\S*\[\d+\]: \([^)]*\) ' .
#    'POP login by user "[^"]+" at \([^)]+\) (\d+\.\d+\.\d+\.\d+)$';

# For cucipop, matching a sample from Daniel Roesen:
#$pat = '^(... .. ..:..:..) \S+ cucipop\[\d+\]: \S+ ' .
#    '(\d+\.\d+\.\d+\.\d+) \d+, \d+ \(\d+\), \d+ \(\d+\)';

# For popa3d with the patch from bartek marcinkiewicz <jr@rzeznia.eu.org>
# (available in contrib/popa3d/):
#$pat = '^(... .. ..:..:..) \S+ popa3d\[\d+\]: ' .
#    'Authentication passed for \S+ -- \[(\d+\.\d+\.\d+\.\d+)\]$';

# A Perdition pattern supplie by Simon Matthews <simon@paxonet.com>.
#$pat = '^(... .. ..:..:..) \S+ perdition\[\d+\]: ' .
#    '(?:Auth:) (\d+\.\d+\.\d+\.\d+)(?:\-\>\d+\.\d+\.\d+\.\d+) ' .
#    'user=(?:\"\S+\") server=(?:\"\S+\") port=(?:\"\S+\") status=(?:\"ok\")';

############################# END OF PATTERNS ##############################


=pod #===================== Match Multiple Patterns ==================START=
# Comment-out the above =pod line to use this function.

# Add as many patterns to the @match array as you like:
my @match = ( $pat, $pat2 );

$_ = qr/$_/ foreach @match; # Pre-compile the regular expressions.

# The maillog line to match is in $_.
sub custom_match
{
    foreach my $regex (@match) {
	# Return timestamp and IP for any (pre-compiled) pattern that matches.
	return ($1, $2) if /$regex/;
    }
    ( );
}
=cut #===================== Match Multiple Patterns ====================END=

=pod #---------------------- vm-pop3d Match Support ------------------START-
# Comment-out the above =pod line to use this function.

# vm-pop3d support by <andy@kahncentral.net>.  Tweaked by Wayne Davison.

# vm-pop3d requires 2 logfile lines to be checked before the user is verified.
# The first line contains the IP and the second lets us know if the user
# successfully logged in or not.

my $vmIpPat = '^(... .. ..:..:..) \S+ (?:vm-pop3d)\[(\d+)\]: '.
       'Connect from (\d+\.\d+\.\d+\.\d+)$';
my $vmUserPat = '\S+ (?:vm-pop3d)\[(\d+)\]: User (\S|\s)+ logged in$';

my($vmTime, $vmPid, $vmIp);

# The maillog line to match is in $_.
sub custom_match
{
    if (/$vmIpPat/o) {
	($vmTime, $vmPid, $vmIp) = ($1, $2, $3);
    }
    elsif (defined($vmPid) && /$vmUserPat/o && $1 == $vmPid) {
	undef $vmPid;
	return ($vmTime, $vmIp);
    }
    ( );
}
=cut #---------------------- vm-pop3d Match Support --------------------END-


########################## Alternate DB/SMTP support #######################
#
# If you need to use something other than DB_File, define your own tie,
# sync, and (optionally) flock functions.
#
########################## Alternate DB/SMTP support #######################

=pod #------------------------ Postfix NDBM_File ---------------------START-
# If you comment-out the preceding =pod line, we'll use NDBM_File instead
# of DB_File.

use NDBM_File;

#$mynet_func = \&mynet_postfix; # Use the default
$tie_func = \&tie_NDBM;
$sync_func = sub { };
$flock = 0;

# We must tie the global %db using the global $dbfile.
sub tie_NDBM
{
    tie %db, 'NDBM_File', $dbfile, O_RDWR|O_CREAT, 0664
	or die "$0: cannot dbopen $dbfile: $!\n";
}
=cut #------------------------ Postfix NDBM_File -----------------------END-

=pod #======================== Postfix BerkeleyDB ====================START=
# If you comment-out the preceding =pod line, we'll use BerkeleyDB instead
# of DB_File.

use BerkeleyDB;

#$mynet_func = \&mynet_postfix; # Use the default
$tie_func = \&tie_BerkeleyDB;
$sync_func = \&sync_BerkeleyDB;
$flock = 0;

my $dbh;

# We must tie the global %db using the global $dbfile.  Also sets $dbh for
# our sync function.
sub tie_BerkeleyDB
{
    $dbh = tie %db,'BerkeleyDB::Hash', -Filename=>"$dbfile.db" -Flags=>DB_CREATE
	or die "$0: cannot dbopen $dbfile: $!\n";
}

sub sync_BerkeleyDB
{
    $dbh->sync and die "$0: sync $dbfile: $!\n";
}
=cut #======================== Postfix BerkeleyDB ======================END=

=pod #-------------------------- qmail tcprules ----------------------START-
# If you comment-out the preceding =pod line, we'll use the tcprules program
# instead of maintaining a DB_File hash.

my $TCPRULES = '/usr/local/bin/tcprules';

$mynet_func = \&mynet_tcprules;
$tie_func = \&tie_tcprules;
$sync_func = \&sync_tcprules;
$flock = 0;

sub mynet_tcprules
{
    # You'll want to edit this value.
    '127.0.0.0/8 192.168.1.1/24';
}

my @qnets;

# We leave the global %db as an untied hash and setup a @qnets array.
sub tie_tcprules
{
    # convert 10.1.3.0/28 to 10.1.3.0-15 
    #     and 10.1.0.0/16 to 10.1.
    # because tcprules doesn't understand nnn.nnn.nnn.nnn/bb netmask formats
    foreach (@mynets) {
	if (m#(.*)/(\d+)#) { 
	    $_ = $1; 
	    my $netbits = (32 - $2);
	    while (int($netbits / 8)) { # for every 8 bits, chop a quad
		s/\.[^.]*$//; 
		$netbits -= 8; 
	    }
	    s/(\d+)$/$1.sprintf("-%d",$1 + (2**$netbits) - 1)/e if $netbits > 0;
	    /(\..*){3}/ or s/$/./;
	} 
	push @qnets, $_;
    }
}

sub sync_tcprules
{
    open(RULES, "|$TCPRULES $dbfile $dbfile.tmp") or die "forking tcprules: $!";
    map { print RULES "$_:allow,RELAYCLIENT=''\n" } @qnets, keys %db;
    print RULES ":allow\n";
    close RULES or die "closing tcprules pipe: $!";
    $log_func->('debug', "wrote tcp rules to $dbfile") if $debug;
}
=cut #-------------------------- qmail tcprules ------------------------END-

=pod #=========================== Courier SMTP =======================START=
# If you comment-out the preceding =pod line, we'll interface with Courier
# SMTP using DB_File.

my $ESMTPD = '/usr/lib/courier/sbin/esmtpd';

use DB_File;

$dbfile = '/etc/courier/smtpaccess'; # DB hash to write
$dbvalue = 'allow,RELAYCLIENT';

$mynet_func = \&mynet_courier;
$tie_func = \&tie_courier;
$sync_func = \&sync_courier;
#$flock_func = \&flock_DB; # Use the default

sub mynet_courier
{
    '';
}

my $dbh;

sub tie_courier
{
    $dbh = tie %db, 'DB_File', "$dbfile.dat", O_CREAT|O_RDWR, 0666, $DB_HASH
	or die "$0: cannot dbopen $dbfile: $!\n";
    if ($flock) {
	my $fd = $dbh->fd;
	open(DB_FH,"+<&=$fd") or die "$0: cannot open $dbfile filehandle: $!\n";
    }
}

sub sync_courier
{
    $dbh->sync and die "$0: sync $dbfile: $!\n" if $write;

    # Reload SMTP Daemon (isn't there a better way to do this?)
    system "$ESMTPD stop; $ESMTPD start";
}
=cut #=========================== Courier SMTP =========================END=

1;
