class Chef
  class RunContext
    def etcd
      @etcd_wrapper ||= EtcdWrapper.new(Etcd.client(host: Chef::Config[:etcd_host], port: Chef::Config[:etcd_port]), [])
    end
  end

  class EtcdWrapper
    extend Forwardable
    def_delegators :_value, :to_s

    def initialize(client, path)
      @client = client
      @path = path
    end

    def method_missing(method, key, *args)
      puts "#{method} #{key}"
      @client.send(method, _key(key), *args)
    end

    def [](key)
      self.class.new(@client, @path + [key])
    end

    private

    def _value
      @client.get(_key).value
    end

    def _key(*extra)
      '/' + (@path + extra).join('/')
    end
  end


  module DSL
    module Recipe
      def etcd
        run_context.etcd
      end
    end
  end
end
