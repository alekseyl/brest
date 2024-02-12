# frozen_string_literal: true

# rubocop:disable Style/ClassVars
module Swaggerizer
  module Blocks
    module Helpers
      module ArrayShortCut
        def typed_items(type, inline_keys = nil, &block)
          data[:items] = Swagger::Blocks::Nodes::ItemsNode
            .call(version: version, inline_keys: { "$ref" => type }.merge(inline_keys || {}), &block)
        end

        def array(name, type, inline_keys = {})
          property(name,
            { type: :array, **inline_keys&.extract!(:synthetic, :virtual, :description, :only_in_schema) }) do
            if [:integer, :string].include?(type)
              items(type: type, **inline_keys)
            else
              typed_items(type, inline_keys)
            end
          end
        end
      end

      module TimeStamps
        def timestamps_properties
          property(:created_at,        type: :string, format: :dateTime)
          property(:updated_at,        type: :string, format: :dateTime)
        end
      end

      module InjectableProperty
        @@injectable_properties ||= {}

        # rubocop:disable Lint/UnderscorePrefixedVariableName
        def property(name, inline_keys = nil, &block)
          if inline_keys&.dig(:virtual)
            @@injectable_properties[name] = [inline_keys.except(:virtual), block]
            nil
          elsif inline_keys&.dig(:inject)
            [*name].each do |_name|
              _inline_keys, _block = @@injectable_properties[_name]
              super(_name, _inline_keys, &_block)
            end
          elsif inline_keys&.delete(:siblings)
            [*name].each do |_name|
              super(_name, inline_keys, &block)
            end
          else
            super(name, inline_keys, &block)
          end
        end
        # rubocop:enable Lint/UnderscorePrefixedVariableName
      end

      module TagsIdsList
        def tags_list
          property(:tag_ids, type: :array, description: "Числовые Id тэгов.") do
            items(type: :integer, format: :int64)
          end
        end
      end

      module SyntheticAttributes
        def property(name, inline_keys = nil, &block)
          Swaggerizer.synthetic_attributes[name] = inline_keys.delete(:synthetic) if inline_keys&.dig(:synthetic)
          super
        end
      end

      module ForeignRelationAttributes
        def property(name, inline_keys = nil, &block)
          Swaggerizer.relation_columns[name] = inline_keys.delete(:foreign_key) if inline_keys&.dig(:foreign_key)
          super
        end
      end

      module JSONB
        def property(name, inline_keys = nil, &block)
          if inline_keys&.dig(:type) == :jsonb
            Swaggerizer.jsonb_attributes[name] = true
            super(name, inline_keys.merge(type: :object), &block)
          else
            super(name, inline_keys, &block)
          end
        end
      end

      module ResponseSchema
        def response_schema(options = {}, &block)
          required = options[:required] ? { required: [*options[:required]] } : {}
          schema do
            property(:data, { **required }, &block)
          end
        end
      end

      def self.add_helpers_to_swagger_blocks
        ::Swagger::Blocks::Nodes::ResponseNode.prepend(ResponseSchema)

        ::Swagger::Blocks::Nodes::PropertyNode.include(TagsIdsList, TimeStamps)
        ::Swagger::Blocks::Nodes::PropertyNode.prepend(ArrayShortCut, JSONB, SyntheticAttributes,
          ForeignRelationAttributes, InjectableProperty)

        ::Swagger::Blocks::Nodes::SchemaNode.include(TagsIdsList, TimeStamps)
        ::Swagger::Blocks::Nodes::SchemaNode.prepend(ArrayShortCut, JSONB, SyntheticAttributes,
          ForeignRelationAttributes, InjectableProperty)
      end
    end
  end
end
# rubocop:enable Style/ClassVars
