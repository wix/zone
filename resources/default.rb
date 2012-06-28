actions :configure, :delete, :install, :start, :stop, :uninstall

attribute :name, :kind_of => String
attribute :path, :kind_of => String
attribute :autoboot, :kind_of => [TrueClass, FalseClass], :default => true
attribute :limitpriv, :kind_of => String, :default => nil
attribute :ip, :kind_of => String
attribute :interface, :kind_of => String
attribute :sysidcfg, :kind_of => String#, :default => nil
# attribute :domain, :kind_of => String
# attribute :default_route, :kind_of => String
# attribute :netmask, :kind_of => String
# attribute :dns_servers, :kind_of => Array
attribute :info, :kind_of => Mixlib::ShellOut, :default => nil
attribute :state, :kind_of => String, :default => nil
# attribute :created, :kind_of => [TrueClass, FalseClass], :default => false
# attribute :installed, :kind_of => [TrueClass, FalseClass], :default => false
# attribute :running, :kind_of => [TrueClass, FalseClass], :default => false

def initialize(*args)
  super
  @action = :install
end
