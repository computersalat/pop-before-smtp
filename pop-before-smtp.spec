Summary: watch log for pop/imap auth, notify Postfix to allow relay
Name: pop-before-smtp
Version: 1.4
Release: 1
Source: https://fridge.oven.com/~bet/src/pop-before-smtp-%{PACKAGE_VERSION}.tar.gz
License: Freely Redistributable
Packager: Bennett Todd <bet@rahul.net>
Group: Networking/Daemons
BuildArchitectures: noarch
BuildRoot: /var/tmp/pop-before-smtp-rpmroot
%description

Spam prevention requires preventing open relaying through email
servers. However, legit users want to be able to relay. If legit
users always stayed in one spot, they'd be easy to describe to the
daemon. However, what with roving laptops, logins from home, etc.,
legit users refuse to stay in one spot.

pop-before-smtp watches the mail log, looking for successful
pop/imap logins, and posts the originating IP address into a
database which can be checked by Postfix, to allow relaying for
people who have recently downloaded their email.

%prep
%setup

%build
echo I see nothing to build here to build

%install
mkdir -p $RPM_BUILD_ROOT/{etc/rc.d/init.d,usr/{sbin,man/man8}}
install popbsmtp.init $RPM_BUILD_ROOT/etc/rc.d/init.d/popbsmtp
install pop-before-smtp $RPM_BUILD_ROOT/usr/sbin/
pod2man pop-before-smtp >$RPM_BUILD_ROOT/usr/man/man8/pop-before-smtp.8

%post
/sbin/chkconfig popbsmtp reset
/etc/rc.d/init.d/popbsmtp start

%preun
/etc/rc.d/init.d/popbsmtp stop
/sbin/chkconfig --level 0123456 popbsmtp off

%files
%defattr(-,root,root)
%doc README
%doc /usr/man/man8/pop-before-smtp.8
%attr(0755,root,root) /usr/sbin/pop-before-smtp
%attr(0755,root,root) /etc/rc.d/init.d/popbsmtp
