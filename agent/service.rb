module MCollective
  module Agent
    class Service<RPC::Agent

      action 'stop' do
        begin
          stop_result = Service.do_service_action('stop', request[:service])

          reply[:status] = stop_result[:status]
          raise stop_result[:msg] if stop_result[:msg]
        rescue => e
          reply.fail! "Could not stop service '%s': %s" % [request[:service], e.to_s]
        end
      end

      action 'start' do
        begin
          start_result = Service.do_service_action('start', request[:service])

          reply[:status] = start_result[:status]
          raise start_result[:msg] if start_result[:msg]
        rescue => e
          reply.fail! "Could not start service '%s': %s" % [request[:service], e.to_s]
        end
      end

      action 'restart' do
        begin
          reply[:status] = Service.do_service_action('restart', request[:service])
        rescue => e
          reply.fail! "Could not restart service '%s': %s" % [request[:service], e.to_s]
        end
      end

      action 'status' do
        begin
          reply[:status] = Service.do_service_action('status', request[:service])
        rescue => e
          reply.fail! "Could not determine status of service '%s': %s" % [request[:service], e.to_s]
        end
      end

      # Loads service provider from config, calls the provider specific action
      # and returns the service status.
      def self.do_service_action(action, service)
        @config = Config.instance

        # Serivice provider defaults to puppet
        provider = @config.pluginconf.fetch('service.provider', 'puppet')
        provider_options = {}

        # Get the provider specific config options from pluginconf
        @config.pluginconf.each do |k, v|
          if k =~ /service\.#{provider}/
            provider_options[k.split('.').last.to_sym] = v
          end
        end

        begin
          Log.debug("Loading Service Provider: %s" % provider)
          provider = "%sService" % provider.capitalize
          PluginManager.loadclass("MCollective::Util::Service::Base")
          PluginManager.loadclass("MCollective::Util::Service::#{provider}")

          svc = Util::Service.const_get(provider).new(service, provider_options)
          Log.debug("Calling %s for service %s" % [action, service])
          return svc.send(action)

        rescue LoadError => e
          raise "Cannot load service provider implementation: %s: %s" % [provider, e.to_s]
        end
      end
    end
  end
end

# vi:tabstop=2:expandtab:ai:filetype=ruby
