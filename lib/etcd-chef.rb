require 'chef/application/solo'
require 'etcd'

module EtcdChef
  class Application < Chef::Application::Solo
    self.options = Chef::Application::Solo.options
    self.banner Chef::Application::Solo.banner

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

      @etcd ||= Etcd.client # TODO: Config
      Chef::Log.debug("Starting etcd watch from index #{@etcd_index || 'nil'}")
      @etcd_index = @etcd.watch('/', @etcd_index).index
    rescue Exception
      # Bump the interval since it should wait on errors, gets reset above
      Chef::Config[:interval] = @original_interval
      raise
    end
  end
end
