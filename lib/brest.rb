# frozen_string_literal: true

require_relative "brest/version"
require_relative "brest/swaggerizer"
require_relative "brest/store_model_jsonb"
require_relative "brest/swaggerizer/parameters"
require_relative "brest/swaggerizer/swagger_blocks_ext"
require_relative "brest/swaggerizer/blocks/helpers"
require_relative "brest/swaggerizer/blocks/operations"
require_relative "brest/nested_select"
require_relative "brest/hash_ext"

module Brest
  class Error < StandardError; end
  # Your code goes here...
end
