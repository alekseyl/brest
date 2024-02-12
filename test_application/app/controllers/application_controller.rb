class ApplicationController < ActionController::Base
  API_VERSION = 1
  PER_PAGE = 20

  # this is only for demoing process for swagger_ui usage
  # and common APIs are better served with JWT :) without cookies
  skip_forgery_protection

  def render_ok(data)
    render json: { data: data, v: API_VERSION }, status: :ok
  end

  def render_err(data, status = :unprocessable_entity)
    message = { errors: { messages: data.respond_to?(:errors) ? data.errors : data[:errors], data: data }, v: API_VERSION }
    render json: message, status: status
  end

  def render_not_found(resource_name = nil)
    render_err({ errors: "#{resource_name || 'Resource' } not found" }, :not_found)
  end

  def render_safe(root = nil, options = {})
    yielded = yield
    render_ok( root ? { root => yielded.as_json(options) } : yielded.as_json(options))
  rescue => e
    render_err(e.trace)
  end

  protected

  def per_page
    params[:per_page].to_i == 0 ? PER_PAGE : params[:per_page].to_i
  end

  def current_page
    params[:page].to_i
  end
end
