require 'chef/application/solo'
require 'chef/config'
require 'etcd'

class Chef
  class Config
    etcd_host 'localhost'
    etcd_port 4001
  end
end

module EtcdChef
  class Application < Chef::Application::Solo
    self.options = Chef::Application::Solo.options
    self.banner Chef::Application::Solo.banner

    option :etcd_host,
      :long  => '--etcd-host HOSTNAME',
      :description => 'The etcd host to use'

    option :etcd_port,
      :long  => '--etcd-port PORT',
      :description => 'The etcd port to use',
      :proc => lambda { |s| s.to_i }

    option :once,
      :long => "--once",
      :description => "Run etcd-chef once and exit",
      :boolean => true

    def run_application
      Chef::Config[:cookbook_path] = [Chef::Config[:cookbook_path]] if Chef::Config[:cookbook_path].is_a?(String)
      Chef::Config[:cookbook_path].unshift(File.expand_path('../etcd-chef/cookbooks', __FILE__))
      @chef_client_json ||= {}
      @chef_client_json['run_list'] ||= []
      @chef_client_json['run_list'].unshift('recipe[etcd-support]')
      super
    end

    def run_chef_client
      @original_interval ||= Chef::Config[:interval]
      Chef::Config[:interval] = 0

      # Pending https://tickets.opscode.com/browse/CHEF-4546
      @chef_client = Chef::Client.new(
        @chef_client_json,
        :override_runlist => config[:override_runlist]
      )
      @chef_client_json = nil unless Chef::Config[:solo]

      @chef_client.run
      @chef_client = nil
      # After CHEF-4546 replace ^^ with super

      if Chef::Config[:once]
        Chef::Application.exit! "Exiting", 0
      else
        @etcd ||= Etcd.client(host: Chef::Config[:etcd_host], port: Chef::Config[:etcd_port], read_timeout: 2592000) # Set the timeout 30 days, pending https://github.com/ranjib/etcd-ruby/pull/7
        Chef::Log.debug("Starting etcd watch from index #{@etcd_index || 'nil'}")
        @etcd_index = @etcd.watch('/', @etcd_index).index
      end
    rescue Exception
      # Bump the interval since it should wait on errors, gets reset above
      Chef::Config[:interval] = @original_interval
      raise
    end
  end
end