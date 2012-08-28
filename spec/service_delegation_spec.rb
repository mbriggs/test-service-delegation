require 'spec_helper'
require_relative '../lib/service_delegation'
require_relative '../lib/service_delegation/api'
require_relative '../lib/service_delegation/mapper'
require_relative '../lib/service_delegation/injector'

describe ServiceDelegation do
  let(:controller_class) do
    Class.new do
      include ServiceDelegation

      def params
        {param: :val}
      end
    end
  end

  let(:controller) {controller_class.new}
  
  def delegate_to(&block)
    controller_class.delegate_to(FakeService, &block)
  end
  
  context "simple delegation" do
    before do
      delegate_to {map(:no_args)}
    end

    it "delegates to the mapped method" do
      FakeService.should_receive(:no_args)
      controller.no_args
    end
  end

  context "mapping to a different method" do
    before do
      delegate_to {map(:foo => :no_args)}
    end

    it "delegates to the mapped method" do
      FakeService.should_receive(:no_args)
      controller.foo
    end
  end

  context "mapping to a method that does not exist" do
    it "raises an error" do
      lambda do
        delegate_to {map(:foo => :whatsit)}
      end.should raise_error(ServiceDelegation::ReceiverNotFound)
    end
  end

  context "mapping to a method with that takes params" do
  
    before do
      delegate_to {map(:params_arg)}
    end

    it "injects params from the controller" do
      controller.params_arg.should == {param: :val}
    end
  end

  context "mapping to a method with a bad param" do
    before do
      delegate_to {map(:yowza_arg)}
    end
    
    it "raises an error" do
      ->{controller.yowza_arg}.should raise_error(ServiceDelegation::IllegalReceiverParameter)
    end
  end
  
  context "mapping to a method which wants a deconstructed parameter" do
    before do
      controller.params[:yowza] = "hi"
      delegate_to {map(:yowza_arg)}
    end
    
    it "raises an error" do
      controller.yowza_arg.should == "hi"
    end
  end
end

module FakeService
  extend self

  def no_args
  end

  def params_arg(params)
    params
  end

  def yowza_arg(yowza)
    yowza
  end
end

