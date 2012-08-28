module ServiceDelegation
  module API
    def delegate_to(service, &block)
      mapper = Mapper.new(service)
      mapper.maps(block) do |map|
        if not service.respond_to? map.receiver
          raise ReceiverNotFound
        end

        define_method(map.sender) do
          begin
            service_injector.call(service.method map.receiver)
          rescue UnknownInjectable => e
            raise IllegalReceiverParameter.new(e.message)
          end
        end
      end
    end
  end
end
