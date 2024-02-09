# frozen_string_literal: true

# rubocop:disable Style/ClassVars
module Swaggerizer
  module SwaggerBlocksExt
    def resource_name
      to_s.underscore.remove(/(_controller_doc|_api_doc)/)
    end

    def index_resource(operation_inline = {}, format = :json, &block)
      path = operation_inline.delete(:path) || "/#{resource_name}/{id}.#{format}"
      swagger_path_ext(path, :get, operation_inline.deep_dup, &block)
    end

    def create_resource(operation_inline = {}, format = :json, &block)
      path = operation_inline.delete(:path) || "/#{resource_name}/{id}.#{format}"
      swagger_path_ext(path, :post, operation_inline.deep_dup, &block)
    end

    def show_resource(operation_inline = {}, format = :json, &block)
      path = operation_inline.delete(:path) || "/#{resource_name}/{id}.#{format}"
      swagger_path_ext(path, :get, operation_inline.deep_dup, &block)
    end

    def update_resource(operation_inline = {}, format = :json, verb = :patch, &block)
      path = operation_inline.delete(:path) || "/#{resource_name}/{id}.#{format}"
      swagger_path_ext(path, verb, operation_inline.deep_dup, &block)
    end

    def delete_resource(operation_inline = {}, format = :json, &block)
      path = operation_inline.delete(:path) || "/#{resource_name}/{id}.#{format}"
      swagger_path_ext(path, :delete, operation_inline.deep_dup, &block)
    end

    def swagger_path_ext(path, verb, operation_inline, &block)
      if path.is_a?(Array)
        swagger_many_path(path, verb, operation_inline, &block)
      else
        swagger_path(path) do
          operation(verb, operation_inline.deep_dup, &block).tap { _1.add_path_params(path) }
        end
      end
    end

    def swagger_many_path(paths, verb, operation_inline, &block)
      [*paths].each do |path|
        swagger_path_ext(path, verb, operation_inline, &block)
      end
    end

    def swagger_schema(name, inline_keys, &block)
      inherit_description(name, nil, inline_keys[:description]) if inline_keys&.dig(:description)
      super(name, inline_keys, &block)
    end

    def inherit_schema(schema_names, parent, inline_keys = nil, &block)
      [*schema_names].each do |name|
        if inline_keys&.dig(:description)
          inline_keys[:description] = inherit_description(name, parent, inline_keys[:description])
        end

        swagger_schema(name, inline_keys) do
          allOf do
            schema("$ref" => parent)
            schema(&block)
          end
        end
      end
    end

    def inherit_description(schema_name, parent, description)
      @@schemas_descriptions ||= {}
      return @@schemas_descriptions[schema_name] = "* #{description}(<b>#{schema_name}</b>)<br/>" unless parent

      @@schemas_descriptions[schema_name] = <<~SCHEMA
        <br/>* #{description} (<b>#{schema_name}</b>)<br/>
        #{@@schemas_descriptions[parent]}
      SCHEMA
    end
  end
end
