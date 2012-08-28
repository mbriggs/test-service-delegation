def load_rails
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
end

RSpec.configure do |config|
  config.order = "random"
end
