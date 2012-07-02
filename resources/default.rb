actions :configure, :delete, :install, :start, :stop, :uninstall

attribute :name, :kind_of => String
attribute :path, :kind_of => String
attribute :autoboot, :kind_of => [TrueClass, FalseClass], :default => true
attribute :limitpriv, :kind_of => String, :default => nil
attribute :ip, :kind_of => String
attribute :interface, :kind_of => String
attribute :password, :kind_of => String
attribute :use_sysidcfg, :kind_of => [TrueClass, FalseClass], :default => true
attribute :sysidcfg_template, :kind_of => String, :default => "sysidcfg.erb"
attribute :copy_sshd_config, :kind_of => [TrueClass, FalseClass], :default => true

attribute :info, :kind_of => Mixlib::ShellOut, :default => nil
attribute :state, :kind_of => String, :default => nil

def initialize(*args)
  super
  @action = :start
end
