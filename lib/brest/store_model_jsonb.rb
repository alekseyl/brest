module StoreModelJsonb
  include ActiveModel::AttributeAssignment

  def serializable_hash(options)
    options = Swaggerizer.as_json_schemas[options] if Swaggerizer.as_json_schemas[options]

    as_json(options&.slice(:only)).merge(
      options&.dig(:include)&.map do |k, v|
        [k, try(k).is_a?(Array) ? try(k).as_json(v) : try(k)&.serializable_hash(v)]
      end&.to_h || {}
    ).compact
  end
end

StoreModel::Model.include(StoreModelJsonb) if defined? StoreModel::Model