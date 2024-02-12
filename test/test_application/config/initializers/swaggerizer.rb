# I need to add this require otherwise the order of eagerloading is misleading for rails
# require 'swagger_blocks'
require 'brest'

::Swaggerizer.extend_swagger_blocks_dsl

Rails.application.config.after_initialize do
  ApplicationRecord.swaggerize(schema: ApidocsController.build_schema)
  ActionController::Parameters.prepend(Swaggerizer::Parameters)
end

