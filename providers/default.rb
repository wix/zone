include Chef::Mixin::ShellOut

def load_current_resource
  @zone = Chef::Resource::Zone.new(new_resource.name)
  @zone.name(new_resource.name)
  @zone.path(new_resource.path)
  @zone.autoboot(new_resource.autoboot)
  @zone.limitpriv(new_resource.limitpriv)
  @zone.ip(new_resource.ip)
  @zone.interface(new_resource.interface)
  @zone.sysidcfg(new_resource.sysidcfg)

  @zone.info(info?)
#  @zone.created(created?)
  @zone.state(state?)
#  @zone.installed(installed?)
#  @zone.running(running?)
end

action :configure do
  unless created?
    Chef::Log.info("Configuring zone #{@zone.name}")
    system("zonecfg -z #{@zone.name} \"create;set zonepath=#{@zone.path};set autoboot=#{@zone.autoboot};#{@zone.limitpriv.nil? ? "" : "set limitpriv=" + @zone.limitpriv};set ip-type=shared;add net;set address=#{@zone.ip};set physical=#{@zone.interface};end;commit\"")
  end
end

action :install do
  action_configure
  unless installed?
    Chef::Log.info("Installing zone #{@zone.name}")
    system("zoneadm -z #{@zone.name} install")
  end
  sysidcfg = @zone.sysidcfg
  file "#{@zone.path}/root/etc/sysidcfg" do
    content sysidcfg
  end
end

action :start do
  action_install
  unless running?
    Chef::Log.info("Booting zone #{@zone.name}")
    system("zoneadm -z #{@zone.name} boot")
  end
end

action :delete do
  action_stop
  if created?
    Chef::Log.info("Deleting zone #{@zone.name}")
    system("zonecfg -z #{@zone.name} delete -F")
  end
end

action :stop do
  if running?
    Chef::Log.info("Halting zone #{@zone.name}")
    system("zoneadm -z #{@zone.name} halt")
  end
end

action :uninstall do
  action_stop
  if installed?
    Chef::Log.info("Uninstalling zone #{@zone.name}")
    system("zoneadm -z #{@zone.name} uninstall -F")
  end
end

private

def created?
  @zone.info.exitstatus.zero?
end


def state?
  @zone.info.stdout.split(':')[2]
end

def info?
  shell_out("zoneadm -z #{@zone.name} list -p")
end

def installed?
  @zone.state == "installed" || @zone.state == "ready" || @zone.state == "running"
end


def running?
  @zone.state == "running"
end
