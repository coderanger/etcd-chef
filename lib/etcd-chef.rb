require 'chef/application/solo'

module EtcdChef
  class AbortWatch < Exception; end

  class Client < Chef::Client
    def setup_run_context(*args)
      super(*args)
    rescue AbortWatch
      Chef::Application.exit!('Aborting etcd watch')
    end
  end

  class Application < Chef::Application::Solo
    self.options = Chef::Application::Solo.options
    self.banner Chef::Application::Solo.banner

    def run_application
      Chef::Config[:interval] = 0
      Chef::Config[:cookbook_path] = [Chef::Config[:cookbook_path]] if Chef::Config[:cookbook_path].is_a?(String)
      Chef::Config[:cookbook_path].unshift(File.expand_path('../etcd-chef/cookbooks', __FILE__))
      @chef_client_json ||= {}
      @chef_client_json['run_list'] ||= []
      @chef_client_json['run_list'].unshift('recipe[etcd-support]')
      super
    end

    def run_chef_client
      @chef_client = EtcdChef::Client.new(
        @chef_client_json,
        :override_runlist => config[:override_runlist]
      )
      @chef_client_json = nil unless Chef::Config[:solo]

      @chef_client.run
      @chef_client = nil
    end
  end
end
