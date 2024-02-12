# I need to add this require otherwise the order of eagerloading is misleading for rails
# require 'swagger_blocks'
require 'swaggerizer/swagger/blocks'
require 'swaggerizer/swagger/params'
require 'swaggerizer/swaggerizer'
ApplicationRecord.swaggerize( schema: ApidocsController.build_schema )
