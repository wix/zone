include Chef::Mixin::ShellOut

def load_current_resource
  @zone = Chef::Resource::Zone.new(new_resource.name)
  @zone.name(new_resource.name)
  @zone.path(new_resource.path)
  @zone.autoboot(new_resource.autoboot)
  @zone.limitpriv(new_resource.limitpriv)
  @zone.ip(new_resource.ip)
  @zone.interface(new_resource.interface)
  @zone.password(new_resource.password)
  @zone.use_sysidcfg(new_resource.use_sysidcfg)
  @zone.sysidcfg_template(new_resource.sysidcfg_template)
  @zone.copy_sshd_config(new_resource.copy_sshd_config)

  @zone.info(info?)
  @zone.state(state?)

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
  
    if @zone.use_sysidcfg
      zone = @zone
      template "#{@zone.path}/root/etc/sysidcfg" do
        source zone.sysidcfg_template
        variables(:zone => zone)
      end
    end
    
    if @zone.copy_sshd_config
      execute "cp /etc/ssh/sshd_config #{@zone.path}/root/etc/ssh/sshd_config"
    end
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
