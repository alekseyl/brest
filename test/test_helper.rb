ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '../dummy'
require File.expand_path('dummy/config/environment.rb', __dir__)

require "rails/test_help"
require "minitest/autorun"
require "bullet"
require_relative "mini_apivore_test_base"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def identify( fixture_name )
    ActiveRecord::FixtureSet.identify(fixture_name)
  end

  def identify_many( *fixtures )
    fixtures.map{|fn| ActiveRecord::FixtureSet.identify(fn) }
  end
  # Add more helper methods to be used by all tests here...
end

def log_ar; ActiveRecord::Base.logger = Logger.new(STDOUT) end
