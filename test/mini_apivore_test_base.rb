require 'mini_apivore'
require 'ostruct'

class MiniApivoreTestBase < ActionDispatch::IntegrationTest
  include ::Warden::Test::Helpers
  include MiniApivore

  init_swagger('/apidocs.json', ApplicationRecord.swagger )

  # swagger checker initialized once per init_swagger call,
  # but when you are testing one schema -- you can inherit from this class only ones,
  # and check resources in dedicated classes.
  # In that case you need redefine original swagger_checker, to map to exact
  def swagger_checker; SWAGGER_CHECKERS[MiniApivoreTestBase] end

  def check_route(verb, path, expected_response_code, **params)
     super(verb, path, expected_response_code, **params ) && response
  end

  def prepare_error_backtrace
    # it will deliver something like this:
    #"/app/test/helpers/base_routes_helpers.rb:57:in `__create_card'",
    #"/app/test/integration/cards_api_test.rb:71:in `block (2 levels) in <class:CommentsApiTest>'",
    "\n" + Thread.current.backtrace[2..-1].slice_after{|trc| trc[/check_route/] }.to_a.last[0..1].join("\n")
  end

  def data_os
    JSON.parse( response.body, object_class: ::OpenStruct ).data
  end

  def error_os
    JSON.parse( response.body, object_class: ::OpenStruct ).errors
  end

end