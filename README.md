
Description
==========

Lightweight resource and provider to manage pkgutil packages for Solaris


Solaris, OpenCSW pkgutil already installed.


Configures, installs and boots Solaris zones.

As of now, it doesn't not reconfigure any options if they have changed
after the initial creation and only a limited sub-set of configuration
options are supported.

New in version 0.0.2:

* /etc/sysidcfg is now created by default from a template.  Turn this off by setting use_sysidcfg to false.
* If copy_sshd_config is true (default), /etc/ssh/sshd_config is copied from the global zone to the new zone.

Requirements
===========

Tested on Solaris x86 5.10.

Attributes
=========

For /etc/sysidcfg:
  node[:zone][:timeserver] - The NTP server to use.
  node[:zone][:timezone] - The timezone for the zone.
  node[:zone][:dns_servers] - Array of DNS servers.


Usage
====

  zone "test" do
    action :start
    path "/opt/zones/test"
    limitpriv "default,dtrace_proc,dtrace_user"
    ip "192.168.31.33/22"
    interface "e1000g0"
    # testpw
    password "whbFxl4vH5guE"
    use_sysidcfg true
    sysidcfg_template "sysidcfg.erb"
    copy_sshd_config false
  end
  
  
Actions:

:install implies :configure
:start implies :install and :configure

:delete implies :stop
