SwaggerUiEngine.configure do |config|
  config.swagger_url = { v1: 'apidocs.json' }
end

SwaggerUiEngine::Engine.routes.default_url_options = Rails.application.config.default_url_options