Summary: Logrotate Puppet Module
Name: pupmod-logrotate
Version: 4.1.0
Release: 2
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: puppet >= 3.3.0
Buildarch: noarch
Requires: simp-bootstrap >= 4.2.0
Obsoletes: pupmod-logrotate-test

Prefix: /etc/puppet/environments/simp/modules

%description
This Puppet module provides the capability to configure logrotate.

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/logrotate

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/logrotate
done

mkdir -p %{buildroot}/usr/share/simp/tests/modules/logrotate

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/logrotate

%files
%defattr(0640,root,puppet,0750)
%{prefix}/logrotate

%post
#!/bin/sh

if [ -d %{prefix}/logrotate/plugins ]; then
  /bin/mv %{prefix}/logrotate/plugins %{prefix}/logrotate/plugins.bak
fi

%postun
# Post uninstall stuff

%changelog
* Fri Jan 16 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-2
- Changed puppet-server requirement to puppet

* Mon Aug 25 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-1
- The upgrade to ruby 2.0 caused empty includes with arrays of length 0.

* Sun Mar 02 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-0
- Refactored to pass all lint tests and be compatible with hiera and puppet 3.
- Added rspec tests for test coverage.

* Thu Feb 13 2014 Kendall Moore <kmoore@keywcorp.com> - 4.0.0-10
- Converted all string booleans into native booleans.

* Mon Oct 07 2013 Kendall Moore <kmoore@keywcorp.com> - 4.0.0-9
- Updated all erb templates to properly scope variables.

* Tue Jul 09 2013 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-8
- Fixed a typo whereby 'include' statements were not processed due to
  extraneous double quotes.
- Moved the tabooext option outside of the main option set since, according to
  the docs, it simply overwrites or appends to the previous value anyway.

* Thu Jan 24 2013 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-7
- Created a Cucumber test that ensures logrotate is working by creating a test log.

* Tue Oct 23 2012 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-6
- Changed the default configuration so that empty files no longer get rotated.

* Fri Aug 17 2012 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-5
- Added the dateext -%Y%m%d.%s so that logs can be rotated multiple times per day.
- Added a default rotate size of 500M to attempt to ensure that the /var/log
  filesystem doesn't rapidly fill.
- Moved the 'conf' portion into the logrotate class by converting it to a
  parameterized class.

* Thu Jun 07 2012 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-4
- Ensure that Arrays in templates are flattened.
- Call facts as instance variables.
- Moved mit-tests to /usr/share/simp...
- Updated pp files to better meet Puppet's recommended style guide.

* Fri Mar 02 2012 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-3
- Improved test stubs.

* Mon Dec 26 2011 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-2
- Updated the spec file to not require a separate file list.

* Mon Dec 05 2011 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-1
- Modified the logrotate 'conf' template to properly detect dateext and flipped
  the dateext variable so that existing systems continue to work the same way.

* Mon Nov 07 2011 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-0
- Set $sharedscripts to 'true' by default.

* Sat Jun 25 2011 Trevor Vaughan <tvaughan@onyxpoint.com> - 2.0.0-2
- No longer manage /etc/logrotate.conf by default.
- Provide a define, logrotate::conf, for customization of /etc/logrotate.conf
- Ensure that the logrotate package is installed and up to date.

* Mon Apr 18 2011 Trevor Vaughan <tvaughan@onyxpoint.com> - 2.0.0-1
- Changed puppet://$puppet_server/ to puppet:///

* Tue Jan 11 2011 Trevor Vaughan <tvaughan@onyxpoint.com> - 2.0.0-0
- Refactored for SIMP-2.0.0-alpha release

* Tue Oct 26 2010 Trevor Vaughan - 1.0-1
- Converting all spec files to check for directories prior to copy.

* Fri May 21 2010 Trevor Vaughan <tvaughan@onyxpoint.com> - 1.0-0
- Doc update and code refactor

* Thu Jan 28 2010 Trevor Vaughan <tvaughan@onyxpoint.com> - 0.1-1
- Changed the default 'rotate' value to 4 instead of 7.

* Wed Nov 04 2009 Trevor Vaughan <tvaughan@onyxpoint.com> - 0.1-0
- Initial module release.
