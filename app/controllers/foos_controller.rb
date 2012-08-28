class FoosController < ApplicationController
  include ServiceDelegation

  delegate_to FooService do
    map(:create) {render 'create'}
  end
end
