#!/usr/bin/perl

$OUTFILE = 'ChangeLog.html';

undef $/; # Slurp entire files.

open(OUT, ">$OUTFILE.new") or die $!;

print OUT <<EOT;
<HTML><HEAD>
<TITLE>POPbSMTP ChangeLog</TITLE>
</HEAD><BODY BGCOLOR=white TEXT=black LINK=blue VLINK=purple>

<A HREF="http://sourceforge.net/"><IMG
SRC="http://sourceforge.net/sflogo.php?group_id=5017" width="88" height="31"
border="0" alt="SourceForge Logo" align=right></A>

<H2>ChangeLog for "popbsmtp" (pop-before-smtp)</H2>

EOT

open(IN, 'ChangeLog') or open(IN, '../ChangeLog') or die $!;
$_ = <IN>;
close(IN);

s/&/&amp;/g;
s/</&lt;/g;
s/>/&gt;/g;

s%^(\d+.+)%</UL></UL><P>$1<UL>%gm;
s%</UL></UL>%%;
s%^\s*\*([\s\S]*?):%</UL><LI><B>$1</B>:<UL><LI>%gm;
s/^\s*- /<LI>/gm;
s/<LI>\s*<LI>/<LI>/g;
s/<BR>\s*<BR>/<BR>/g;
s%(<UL>\s*)</UL>%$1%g;

s%(Upped the version (?:number )?to \S+\.)%<FONT COLOR=red>$1</FONT>%g;

print OUT $_, <<EOT;
</UL></UL>
</BODY></HTML>
EOT

close(OUT);

rename("$OUTFILE.new", $OUTFILE);

print "Updated $OUTFILE\n";
