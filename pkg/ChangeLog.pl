#!/usr/bin/perl

$OUTFILE = 'ChangeLog.shtml';

undef $/; # Slurp entire files.

open(OUT, ">$OUTFILE.new") or die $!;

print OUT <<EOT;
<html><head>
<title>Pop-before-smtp ChangeLog</title>
</head><body bgcolor=white text=black link=blue vlink=purple>

<!--#include virtual="/top.html" -->

<h2>ChangeLog for "popbsmtp" (pop-before-smtp)</h2>

EOT

open(IN, 'ChangeLog') or open(IN, '../ChangeLog') or die $!;
$_ = <IN>;
close(IN);

s/&/&amp;/g;
s/</&lt;/g;
s/>/&gt;/g;

s#^(\d+.+)#</UL></UL><P>$1<UL>#gm;
s#</UL></UL>##;
s#^\s*\*([\s\S]*?): *#</UL><LI><B>$1</B>:<UL><LI>#gm;
s/^\s*[-+] /<LI>/gm;
s/<LI>\s*<LI>/<LI>/g;
s/<BR>\s*<BR>/<BR>/g;
s#(<UL>\s*)</UL>#$1#g;

s#((?:Released version|Upped the version (?:number )?to) \S+)#<FONT COLOR=red>$1</FONT>#g;

print OUT $_, <<EOT;
</UL></UL>

<p> Return to the <a href="/">home page</a>.
EOT

close(OUT);

rename("$OUTFILE.new", $OUTFILE);

print "Updated $OUTFILE\n";
