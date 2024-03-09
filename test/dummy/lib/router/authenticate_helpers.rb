# frozen_string_literal: true

module AuthenticateHelpers
  # NOTE: constraints is about route matching, even used dynamically it still will
  # try to match routes, returning false will NOT MATCH the route, resulting in routing error
  #
  # NOTE 2: method with bang throwing warden error, and will STOP matching
  # and all actions will be switching to FailApp
  def authenticate!(scopes = nil, &block)
    constraints(->(request) {
      authenticate_any_scope(request, scopes) ||
        throw(:warden, message: "No scope was able to authenticate: #{scopes}!")
    }, &block)
  end

  def authenticate(scopes = nil, &block)
    constraints(->(request) {  authenticate_any_scope(request, scopes) }, &block)
  end

  def authenticated?(scope = nil, &block)
    constraints(->(request) { request.env["warden"].authenticated?(scope: scope) }, &block)
  end

  def authenticate_any_scope(request, scopes)
    [*scopes].any? { |auth_scope| break true if request.env["warden"].authenticate(scope: auth_scope) }
  end
end
