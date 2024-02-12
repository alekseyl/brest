module Swaggerizer
  module ActiveRecordSwaggerizer
    @@swagger ||= {}

    # jsonb fields should be included/selected differently
    def jsonb_attributes; @@jsonb_attributes ||= {} end
    def synthetic_attributes; @@synthetic_attributes ||= {} end
    def relation_columns; @@relation_columns ||= {} end
    # values: :any, [:only_schema_1, :only_schema_2]
    def array_columns; @@array_columns ||= {} end

    def as_json(options = self.to_s.to_sym); as_json_schemas[options] || super(options) end

    def swaggerize(rebuild: false, schema:)
      return swagger unless (swagger.blank? || rebuild)
      self.swagger = schema
      @@as_json_schemas = nil
      # will build schema inside
      as_json_schemas
      permit_schemas
    end

    def as_json_schemas; (@@as_json_schemas ||= build_as_json_schemas).freeze end

    def permit_schemas; (@@permit_schemas ||= build_permit_schemas ).freeze end

    def swagger; @@swagger end
    def swagger=(new_schema); @@swagger = new_schema end

    def build_permit_schemas
      as_json_schemas.inject({}){|sum,(k,v)| { **sum, **build_permit_schema({ k => v }, k)} }
    end

    def build_permit_schema( schema, root )
      return if schema.blank?
      schema.transform_values do |v|
        [*v[:only], *build_permit_schema(v[:include], root )&.map{ |k,val| {k=>val} }]
          .compact
          .map!{ |res|
            array_columns[res] == :any || array_columns[res].try(:include?,root) ? {res => []} : res
          }
      end
    end

    # compact_hash_to_array
    # { obj: { obj2: {}, obj3: {} } } => {obj: [:obj2, :obj3]}
    # { obj: { obj2: {} } } => {obj: :obj2} , { obj: {}} => :obj
    def compact_hash(hash_to_compact)
      need_convert = false
      result = hash_to_compact.map { |k, v|
        need_convert = need_convert || v.blank?
        v.blank? ? k.to_sym : [k, compact_hash(v)]
      }

      if need_convert
        result = [*result.select { |v| v.is_a?(Symbol) }, result.select { |v| !v.is_a?(Symbol) }.to_h].reject(&:blank?)
        result = result.length == 1 ? result[0] : result
      else
        result = result.to_h if result.is_a?(Array)
      end

      result.is_a?( Hash ) ? [result] : result
    end

    def build_as_json_schemas
      result = {}
      swagger[:definitions].each do |k, v|
        # schema could be cross referenced and built during previous execution
        result[k] ||= build_single_as_json_schema(v, result)
      end

      # after first run
      result.transform_values! { |v| unnest_include(v) }
    end

    def unnest_include(schema)
      # [{include: {img: {}}}, {include: {payload: {}}}] => {img: { only: :old_schema }, payload: { only: :old_schema }}
      _include = schema.select { |el| !el.is_a?(Symbol) }&.map { |el| el&.dig(:include) }.map(&:to_a).flatten(1).to_h

      # {img: { only: :old_schema }, payload: { only: :old_schema }} -> {img: { only: :new_schema }, payload: { only: :new_schema }}
      _include.transform_values! { |v| unnest_include(v[:only]) }
      {
        only: schema.select { |el| el.is_a?(Symbol) },
        **(_include.blank? ? {} : { include: _include })
      }
    end

    def build_single_as_json_schema(v, schema)
      # "$ref" => "#/definitions/CardPreview",
      if v.is_a?(String)
        path = v.split('/')[1..-1].map(&:to_sym)
        # path[-1] = CardPreview, i.e. schema_name
        return schema[path[-1]] ||= build_single_as_json_schema(swagger.dig(*path), schema)
      end

      if v[:allOf]
        [
          *build_properties(v[:allOf][1][:properties], schema),
          *build_single_as_json_schema(v[:allOf][0]['$ref'], schema)
        ].sort do |a, b|
          if a.is_a?(Symbol) && b.is_a?(Symbol)
            a <=> b
          else
            a.is_a?(Symbol) ? -1 : 1
          end
        end
      else
        build_properties(v[:properties], schema)
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
          objects[:include][k] = { only: build_single_as_json_schema(v.dig(:items, '$ref') || v['$ref'], schema) }
        else
          result << k.to_sym
        end

      end
      result << objects unless objects[:include].blank?
      result
    end

    def includeable?(key, items = nil)
      case (key)
        # type => ['object', 'null']
      when Array
        key.map(&:to_sym).include?(:object)
        # type => :object
      when :object, 'object'
        true
        # type: :array
        # items: { '$ref' => SchemaName }
        # items: { type => :object, properties: {} } ?
      when 'array', :array
        !!items&.dig('$ref') || items&.dig(:type)&.to_sym == :object
      else
        false
      end
    end
  end

  module AsJsonSwaggerized
    def as_json(options = nil)
      super(Swaggerizer.as_json_schemas[options] ? Swaggerizer.as_json_schemas[options] : options).deep_compact
    end
  end

  extend ActiveRecordSwaggerizer
end
