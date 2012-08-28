module FooService
  extend self

  def create(params)
    Foo.create(params)
  end
end
