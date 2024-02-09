# frozen_string_literal: true

# rubocop:disable Style/ClassVars
module Swaggerizer
  # ActiveRecord Adapter!
  module ActiveRecordSwaggerizer
    extend ActiveSupport::Concern

    included do
      include AsJsonSwaggerized

      scope :select_sw, ->(sw_model_name) { select(*Swaggerizer.get_select_schema_with_relations(sw_model_name)) }

      scope :includes_sw, ->(sw_model_name) {
        Swaggerizer.includes_schemas[sw_model_name].blank? ? nil # rubocop:disable Style/MultilineTernaryOperator
          : includes(*Swaggerizer.includes_schemas[sw_model_name])
      }

      scope :includes_sw_poly, ->(models) {
        Swaggerizer.includes_schemas.slice(*models).blank? ? nil # rubocop:disable Style/MultilineTernaryOperator
          : includes(Swaggerizer.includes_schemas.slice(*models).values.flatten(1))
      }

      scope :scope_as_swagger_model, ->(sw_model_name) { includes_sw(sw_model_name).select_sw(sw_model_name) }
      scope :swaggerize_output, ->(sw_model_name) {
        includes_sw(sw_model_name).select_sw(sw_model_name).as_json(sw_model_name)
      }
    end

    module ClassMethods
      @@swagger ||= {}

      # jsonb fields should be included/selected differently
      def jsonb_attributes; @@jsonb_attributes ||= {} end

      def synthetic_attributes; @@synthetic_attributes ||= {} end

      def relation_columns; @@relation_columns ||= {} end

      # values: :any, [:only_schema_1, :only_schema_2]
      def array_columns; @@array_columns ||= {} end

      def as_json(options = to_s.to_sym); as_json_schemas[options] || super(options) end

      def swaggerize(rebuild: false, schema:)
        return @@swagger unless @@swagger.blank? || rebuild

        @@swagger = schema
        @@as_json_schemas = nil
        @@include_schemas = nil
        @@select_schemas = nil
        # will build schema inside
        as_json_schemas
        permit_schemas
        includes_schemas
        @@swagger = clear_ext_keys(@@swagger)
      end

      def as_json_schemas; (@@as_json_schemas ||= extract_plain_as_json_schemas_from_swagger).freeze end

      def includes_schemas; (@@include_schemas ||= build_includes_schemas).freeze end

      def permit_schemas; (@@permit_schemas ||= build_permit_schemas).freeze end

      # AR does not support nested select, so it would be only first level select adjustment
      def select_schemas; (@@select_schemas ||= build_select_schemas).freeze end

      def swagger; @@swagger end

      def build_permit_schemas
        as_json_schemas.inject({}) { |sum, (k, v)| { **sum, **build_permit_schema({ k => v }, k) } }
      end

      def build_permit_schema(schema, root)
        return if schema.blank?

        schema.transform_values do |v|
          [*v[:only], *build_permit_schema(v[:include], root)&.map { |k, val| { k => val } }].compact
            .map! do |res|
              array_columns[res] == :any || array_columns[res].try(:include?, root) ? { res => [] } : res
            end
        end
      end

      def get_select_schema_with_relations(schema_name)
        [:id, *select_schemas[schema_name]].uniq +
          [*includes_schemas[schema_name]].map do |v|
            relation_columns[v] || relation_columns[v.try(:keys)&.first]
          end.compact
      end

      # select schemas will include :id even if it wasn't described in the schema,
      # because otherwise it might break relations
      def build_select_schemas
        as_json_schemas.each_with_object({}) do |(k, v), sum|
          sum[k] = [*v[:only], *(v[:include]&.keys&.select { |ik| jsonb_attributes[ik] })]
            .reject { |attr| synthetic_attr?(attr, k) }
        end.transform_values! { |v| v.include?(:id) ? v : v << :id }
      end

      def build_includes_schemas
        as_json_schemas.select { |_k, v| v[:include] }
          .transform_values { |v| compact_hash(build_single_include_schema(v[:include])) }
      end

      def clear_ext_keys(schema = swagger)
        schema.transform_values! do |v|
          if v.is_a?(Hash)
            v.delete(:only_in_schema)
            clear_ext_keys(v)
          else
            v
          end
        end
      end

      def build_single_include_schema(schema_include)
        return {} unless schema_include.is_a?(Hash)

        schema_include.reject { |k, _v| jsonb_attributes[k] || synthetic_attr?(k) }
          .map { |k, v| [k, build_single_include_schema(v[:include])] }.to_h
      end

      # compact_hash_to_array
      # { obj: { obj2: {}, obj3: {} } } --> {obj: [:obj2, :obj3]}
      # { obj: { obj2: {} } } --> {obj: :obj2} ,
      # { obj: {}} --> :obj
      def compact_hash(hash_to_compact)
        need_convert = false
        result = hash_to_compact.map do |k, v|
          need_convert ||= v.blank?
          v.blank? ? k.to_sym : [k, compact_hash(v)]
        end

        if need_convert
          # transformation??
          result = [
            *result.select { _1.is_a?(Symbol) },
            result.select { !_1.is_a?(Symbol) }.to_h,
          ].reject(&:blank?)
          result = result.length == 1 ? result[0] : result
        elsif result.is_a?(Array)
          result = result.to_h
        end

        result.is_a?(Hash) ? [result] : result
      end

      def synthetic_attr?(key, schema = nil)
        synthetic_attributes[key].is_a?(Symbol) ? schema.to_s[/#{synthetic_attributes[key]}/] # rubocop:disable Style/MultilineTernaryOperator
          : synthetic_attributes[key]
      end

      # will de-refer all models cross referring and extract
      # all $ref => '' to plain tree structure
      def extract_plain_as_json_schemas_from_swagger
        result = {}
        swagger[:definitions].each do |k, v|
          @k = k
          # schema could be cross referenced and built during previous execution
          result[k] ||= build_model_plain_as_json_schema(v, result)
        end

        # after first run
        result.transform_values! { |v| unnest_include(v) }
      rescue => e
        raise BuildError, "failed to build schema: #{@k}, e trace: #{e.backtrace}"
      end

      # rubocop:disable Lint/UnderscorePrefixedVariableName
      def unnest_include(schema)
        # [{include: {img: {}}}, {include: {payload: {}}}] -->
        #   {img: { only: :old_schema }, payload: { only: :old_schema }}
        _include = schema.select { |el| !el.is_a?(Symbol) }
          .map { |el| el&.dig(:include) }
          .map(&:to_a).flatten(1).to_h

        # {img: { only: :old_schema }, payload: { only: :old_schema }} ->
        #   {img: { only: :new_schema }, payload: { only: :new_schema }}
        _include.transform_values! { |v| unnest_include(v[:only]) }
        {
          only: schema.select { |el| el.is_a?(Symbol) },
          **(_include.blank? ? {} : { include: _include }),
        }
      end
      # rubocop:enable Lint/UnderscorePrefixedVariableName

      # "$ref" => "#/definitions/CardPreview",
      def find_existing_model(ref_path)
        path = ref_path.split("/")[1..-1].map(&:to_sym)
        # path[-1] = CardPreview, i.e. schema_name
        existing_schema = swagger.dig(*path)
        raise ModelNotFoundError, "No model found in swagger definition for path: #{ref_path}!" if existing_schema.nil?

        existing_schema
      end

      # "$ref" => "#/definitions/CardPreview",
      def model_name_from_ref_path(v)
        v.split("/")[1..-1].map(&:to_sym)[-1]
      end

      def build_model_plain_as_json_schema(v, model_schema)
        if v.is_a?(String)
          model_name = model_name_from_ref_path(v)
          return model_schema[model_name] ||= build_model_plain_as_json_schema(find_existing_model(v), model_schema)
        end

        if v[:allOf]
          [
            *build_properties(v[:allOf][1][:properties], model_schema),
            *build_model_plain_as_json_schema(v[:allOf][0]["$ref"], model_schema),
          ].sort do |a, b|
            if a.is_a?(Symbol) && b.is_a?(Symbol)
              a <=> b
            else
              a.is_a?(Symbol) ? -1 : 1
            end
          end
        else
          build_properties(v[:properties], model_schema)
        end
      end

      def build_properties(props, schema)
        result = []
        objects = { include: {} }
        props.each do |k, v|
          # this needed for permit_schemas
          if v[:type] == :array
            array_columns[k.to_sym] = v[:only_in_schema] ? [*array_columns[k.to_sym], v[:only_in_schema]].compact : :any
          end

          if includeable?(v[:type], v[:items])
            # items: { '$ref' => SchemaName } || '$ref' => SchemaName
            objects[:include][k] = {
              only: build_model_plain_as_json_schema(v.dig(:items, "$ref") || v["$ref"], schema),
            }
          else
            result << k.to_sym
          end
        end
        result << objects unless objects[:include].blank?
        result
      end

      def includeable?(key, items = nil)
        case key
          # type => ['object', 'null']
        when Array
          key.map(&:to_sym).include?(:object)
          # type => :object
        when :object, "object"
          true
          # type: :array
          # items: { '$ref' => SchemaName }
          # items: { type => :object, properties: {} } ?
        when "array", :array
          !!items&.dig("$ref") || items&.dig(:type)&.to_sym == :object
        else
          false
        end
      end
    end
  end

  module AsJsonSwaggerized
    def as_json(options = nil)
      super(Swaggerizer.as_json_schemas[options] ? Swaggerizer.as_json_schemas[options] : options).deep_compact
    end
  end

  extend ActiveRecordSwaggerizer::ClassMethods

  class ModelNotFoundError < StandardError; end
  class BuildError < StandardError; end

  def self.extend_swagger_blocks_dsl
    ::Swaggerizer::Blocks::Helpers.add_helpers_to_swagger_blocks
    ::Swagger::Blocks::Nodes::OperationNode.include(::Swaggerizer::Blocks::Operations)
  end
end
# rubocop:enable Style/ClassVars
