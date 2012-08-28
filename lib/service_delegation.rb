module ServiceDelegation
  def self.included(klass)
    klass.extend(API)
    include ControllerMethods
  end

  module ControllerMethods
    def service_injector
      @service_injector ||= Injector.new([ControllerDelegateSource.new(self)])
    end
  end

  class ControllerDelegateSource
    attr_accessor :controller

    def initialize(controller)
      self.controller = controller
    end

    def sources(injector)
      {
       params: prop(:params),
       user: prop(:current_user),
       site: prop(:current_site),
       account: prop(:current_account),
       company: prop(:current_company)
      }.merge(param_sources)
    end

    def prop(method)
      ->{controller.send(method)}
    end

    def param_sources
      controller.params.reduce({}) do |result, (k, v)|
        result.tap { |r| r[k] = ->{v} }
      end
    end
  end

  class ReceiverNotFound < Exception; end
  class IllegalReceiverParameter < Exception; end
end

