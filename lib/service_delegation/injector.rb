# stolen from raptor
# https://github.com/garybernhardt/raptor/blob/master/lib/raptor/injector.rb

module ServiceDelegation
  class Injector
    def initialize(injectables=[])
      @injectables = injectables
    end

    def sources
      # Merge all injectables' sources into a single hash
      @sources ||= @injectables.map do |injectable|
        injectable.sources(self)
      end.inject({}, &:merge)
    end

    def call(method)
      args = self.args(method)
      method.call(*args)
    end

    def args(method)
      method = injection_method(method)

      parameters(method).select do |type, name|
        name && type != :rest && type != :block
      end.reject do |type, name|
        type == :opt && sources[name].nil?
      end.map do |type, name|
        source_proc = sources[name] or raise UnknownInjectable.new(name)
        source_proc.call
      end
    end

    def parameters(method)
      method.parameters
    end

    def injection_method(method)
      if method.name == :new
        method.receiver.instance_method(:initialize)
      else
        method
      end
    end
  end

  class UnknownInjectable < RuntimeError
    def initialize(name)
      super("Unknown injectable name: #{name.inspect}")
    end
  end
end
