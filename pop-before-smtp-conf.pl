# This config file is a perl library that can override various aspects of the
# pop-before-smtp script's setup.  Install it as /etc/pop-before-smtp-conf.pl

use vars qw(
    $pat
    $write
    $flock
    $debug
    $reprocess
    $dbfile
    $grace
    %file_tail
    $log_func
);

#
# Override the default options here (or use the command-line options):
#

# Clear to avoid our exclusive file locking when updating the DB.
#$flock = 0;

# Set to output some extra log messages.
#$debug = 1;

# Override the DB hash file we will create/update (".db" gets appended).
#$dbfile = '/etc/postfix/pop-before-smtp';

# A 30-minute grace period before the IP is expired.
#$grace = 1800;

# Set the log file we will watch for pop3d/imapd records.
#$file_tail{'name'} = '/var/log/maillog';

# ... or we'll try to figure it out for you.
if (!-f $file_tail{'name'}) {
    foreach (qw( /var/log/mail/info /var/log/messages /var/adm/messages )) {
	if (-f $_) {
	    $file_tail{'name'} = $_;
	    last;
	}
    }
}

# If postconf isn't somewhere on this PATH, uncomment and customize.
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

#===========================================================================
# If you want to output a log file of what pop-before-smtp is doing, you have a
# few choices: either call set_output_log('FILE'), uncomment the syslog lines
# below, or put a reference to your own custom logging function in $log_func.

#set_output_log('/var/log/pop-before-smtp');

# Uncomment these 3 lines to cause log messages to use syslog().
#use Sys::Syslog;
#openlog('pop-before-smtp', 'pid', 'mail');
#$log_func = \&syslog;
#===========================================================================

#############################START OF PATTERNS##############################
#
# Pick one of these values for the $pat variable OR define a subroutine
# named "custom_match" to handle a more complex match scenario (there's
# and example below).  Feel free to delete all the stuff you don't need.
#
#############################START OF PATTERNS##############################

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
#$pat = '^(... .. ..:..:..) \S+ q?popper\S+\[\d+\]: .*\s(\d+.\d+.\d+.\d+)$';

# For Cyrus, Kenn Martin <kmartin@infoteam.com>, with tweak
# from William Yodlowsky for IP addrs that don't resolve:
#$pat = '^(... .. ..:..:..) \S+ (?:pop3d|imapd)\[\d+\]: ' .
#    'login: \S*\[(\d+\.\d+\.\d+\.\d+)\] \S+ \S+';

# For Courier-POP3 and Courier-IMAP:
#$pat = '^(... .. ..:..:..) \S+ (?:courierpop3|imap)login: ' .
#    'LOGIN, user=\S+, ip=\[[:f]*(\d+\.\d+\.\d+\.\d+)\]$';

# For qmail's pop3d:
#$pat = '^(... .. ..:..:..) \S+ vpopmail\[\d+\]: ' .
#    'vchkpw: login \[\S+\] from (\d+\.\d+\.\d+\.\d+)$';

# For Qpopper POP/APOP Server
#$pat = '^(... .. ..:..:..) \S+ (?:qpopper)\[\d+\]: Stats: \S+ ' .
#    '(?:\d+ ){4}(\d+.\d+.\d+.\d+)';

# Alex Burke's popper install
#$pat = '^(... .. ..:..:..) \S+ popper\[\d+\]: Stats: \S+ ' .
#    '(?:\d+ ){4}(?:\S+ )?(\d+.\d+.\d+.\d+)$';

# Chris D.Halverson's pattern for Qpopper 3.0b29 on Solaris 2.6
#$pat = '^(\w{3} \w{3} \d{2} \d{2}:\d{2}:\d{2} \d{4}) \[\d+\] ' .
#    ' Stats:\s+\w+ \d \d \d \d [\w\.]+ (\d+\.\d+\.\d+\.\d+)';

# Nick Bauer <nickb@inc.net> has something completely different as
# a qpopper logfile format
#$pat = '^(... .. ..:..:..) \S+ qpopper\S+\[\d+\]: \([^)]*\) POP login ' .
#    'by user "[^"]+" at \([^)]+\) (\d+.\d+.\d+.\d+)$';

# For cucipop, matching a sample from Daniel Roesen:
#$pat = '^(... .. ..:..:..) \S+ cucipop\[\d+\]: \S+ ' .
#    '(\d+\.\d+\.\d+\.\d+) \d+, \d+ \(\d+\), \d+ \(\d+\)';

# For popa3d with the patch from bartek marcinkiewicz <jr@rzeznia.eu.org>
# (available in contrib/popa3d/):
#$pat = '^(... .. ..:..:..) \S+ popa3d\[\d+\]: ' .
#    'Authentication passed for \S+ -- \[(\d+.\d+.\d+.\d+)\]$';

# A Perdition pattern supplie by Simon Matthews <simon@paxonet.com>.
#my $pat = '^(... .. ..:..:..) \S+ perdition\[\d+\]: ' .
#    '(?:Auth:) (\d+.\d+.\d+.\d+)(?:\-\>\d+.\d+.\d+.\d+) ' .
#    'user=(?:\"\S+\") server=(?:\"\S+\") port=(?:\"\S+\") status=(?:\"ok\")';

##############################END OF PATTERNS###############################


=pod #----------------------------------------------------------------------
# vm-pop3d support by <andy@kahncentral.net>.
#
# Comment-out the =pod and =cut lines to use this function.

my $vmIpPat = '^(... .. ..:..:..) \S+ (?:vm-pop3d)\[(\d+)\]: '.
       'Connect from (\d+\.\d+\.\d+\.\d+)$';
my $vmUserPat = '\S+ (?:vm-pop3d)\[(\d+)\]: User (\S|\s)+ logged in$';

# vm-pop3d requires 2 logfile lines to be checked before the user is verified.
# The first line contains the IP and the second lets us know if the user
# successfully logged in or not.

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
=cut #----------------------------------------------------------------------

1;
