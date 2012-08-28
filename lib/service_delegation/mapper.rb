module ServiceDelegation
  class Mapper
    attr_accessor :target, :mappings

    def initialize(target)
      self.target = target
      self.mappings = []
    end

    def map(method)
      sender, receiver = parse_method(method)


      mappings << Mapping.new(sender: sender,
                              receiver: receiver)
    end

    def maps(perform_maps, &each_mapping)
      instance_eval(&perform_maps)
      mappings.each(&each_mapping)
    end

    def parse_method(method)
      case method
      when Hash then method.to_a.first
      when Symbol then [method, method]
      end
    end

    class Mapping
      attr_accessor :sender, :receiver

      def initialize(args)
        args.each do |arg, val|
          send("#{arg}=", val)
        end
      end
    end
  end
end
