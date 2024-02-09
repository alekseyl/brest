# Swagger blocks helpers
module Swagger
  module Blocks
    extend ActiveSupport::Concern

    module ClassMethods
      def resource_name
        self.to_s.underscore.remove('_api_doc')
      end

      def index_resource( operation_inline = {}, format = :json, &block)
        swagger_path( operation_inline.delete(:path) || "/#{resource_name}.#{format}" ) do
          operation( :get, operation_inline.deep_dup, &block)
        end
      end

      def create_resource( operation_inline = {}, format = :json,  &block)
        swagger_path( operation_inline.delete(:path) || "/#{resource_name}.#{format}" ) do
          operation( :post, operation_inline.deep_dup, &block)
        end
      end

      def show_resource( operation_inline = {}, format = :json, &block)
        swagger_path( operation_inline.delete(:path) || "/#{resource_name}/{id}.#{format}" ) do
          operation( :get, operation_inline.deep_dup, &block)
        end
      end

      def update_resource( operation_inline = {}, format = :json, verb = :patch, &block)
        swagger_path( operation_inline.delete(:path) || "/#{resource_name}/{id}.#{format}" ) do
          operation( verb, operation_inline.deep_dup, &block )
        end
      end

      def delete_resource( operation_inline = {}, format = :json, &block)
        swagger_path( operation_inline.delete(:path) || "/#{resource_name}/{id}.#{format}" ) do
          operation( :delete, operation_inline.deep_dup, &block )
        end
      end

      alias_method :swagger_path_old, :swagger_path
      def swagger_path(path, &block)
        [*path].each{ |_path| swagger_path_old(_path, &block) }
      end

      alias_method :swagger_schema_old, :swagger_schema
      def swagger_schema(name, inline_keys, &block)
        inherit_description(name, nil, inline_keys[:description]) if inline_keys&.dig(:description)
        swagger_schema_old(name, inline_keys, &block)
      end

      def inherit_schema(schema_names, parent, inline_keys = nil, &block)
        [*schema_names].each do |name|
          inline_keys[:description] = inherit_description( name, parent, inline_keys[:description]  ) if inline_keys&.dig(:description)

          swagger_schema name, inline_keys do
            allOf do
              schema '$ref' => parent
              schema(&block)
            end
          end
        end
      end

      def inherit_description( schema_name, parent, description )
        @@schemas_descriptions ||= {}
        return @@schemas_descriptions[schema_name] = "* #{description}(<b>#{schema_name}</b>)<br/>" unless parent

        @@schemas_descriptions[schema_name] = <<~SCHEMA
          <br/>* #{description} (<b>#{schema_name}</b>)<br/>
          #{@@schemas_descriptions[parent]}
          SCHEMA
      end
    end

    module ArrayShortCut
      def typed_items( type, inline_keys = nil, &block )
        self.data[:items] = Swagger::Blocks::Nodes::ItemsNode.
          call(version: version, inline_keys: { '$ref' => type }.merge( inline_keys || {} ), &block)
      end

      def array( name, type, inline_keys = {} )
          property name, {type: :array, **inline_keys&.extract!(:synthetic, :virtual, :description, :only_in_schema) } do
            %i[integer string].include?( type ) ? items( type: type, **inline_keys )
              : typed_items( type, inline_keys )
          end
      end
    end

    module ResponseSchema
      def response_schema(options = {}, &block)
        required = options[:required] ? { required: [*options[:required]] } : {}
        schema do
          property :data, {**required}, &block
        end
      end
    end

    Nodes::PropertyNode.prepend(ArrayShortCut)

    Nodes::SchemaNode.prepend(ArrayShortCut)

    Nodes::ResponseNode.prepend(ResponseSchema)
  end
end
