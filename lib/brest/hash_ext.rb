module HashExt
  # expected options structure:
  # :only => [
  #        [0] :name
  #     ],
  #  :include => {
  #     :jsonb_model => {
  #        :only => [
  #             [0] :address,
  #             [1] :zip_code,
  #        ]
  #  },
  def serializable_hash(options)
    first_level_serialization = options[:only] ? slice(*options[:only].map(&:to_s), *options[:only].map(&:to_sym)) : {}
    nested_serialization = (options[:include] || {}).map{|attr, structure| [attr, self[attr].serializable_hash(structure)] }.to_h

    { **first_level_serialization, **nested_serialization }
  end

  def deep_compact
    compact.transform_values do |vl|
      vl.try(:deep_compact) || vl.is_a?(Array) && vl.map{|el| el.try(:deep_compact) || el } || vl
    end
  end

end

Hash.include(HashExt)