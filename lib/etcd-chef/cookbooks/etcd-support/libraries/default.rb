class Chef
  class RunContext
    attr_accessor :etcd_client, :etcd_index

    def etcd
      @etcd_wrapper ||= EtcdWrapper.new(self, [])
    end
  end

  class EtcdWrapper
    extend Forwardable
    def_delegators :_value, :to_s

    def initialize(run_context, path)
      @run_context = run_context
      @path = path
    end

    def method_missing(method, key, *args)
      puts "#{method} #{key}"
      @run_context.etcd_client.send(method, _key(key), *args)
    end

    def [](key)
      self.class.new(@run_context, @path + [key])
    end

    private

    def _value
      @run_context.etcd_client.get(_key).value
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
