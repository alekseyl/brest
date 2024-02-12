module HashExt
  def << (ar); self[ar.try(:id) || ar.to_param] = ar; self end

  def serializable_hash(options)
    (options[:only] ? slice(*options[:only]) : {}).merge(
      !options[:include] ? {} : options[:include].keys.map{|k| [k, self[k].serializable_hash(options[:include][k])] }.to_h
    )
  end

  def & (other)
    if other.is_a?(Array)
      keys.inject({}) do |sum, k|
        sum.update(k => self[k].is_a?(Array) ? (other & self[k]) : self[k] )
      end
    elsif other.is_a?(Hash)
      inject({}) do |sum, (k,v)|
        sum.update(k => other[k].is_a?(Hash) && v.is_a?(Hash) ? other[k] & v : [*other[k]] & v )
      end
    else
      {}
    end
  end

  def | (other)
    if other.is_a?(Array)
      keys.inject({}) do |sum, k|
        sum.update(k => ( self[k].is_a?(Array) ? (other | self[k]) : self[k] ) )
      end
    elsif other.is_a?(Hash)
      (keys + [*other&.keys]).inject({}) do |sum, k|
        # it should work like default merge on keys present on only one of hashes
        value = other[k] || self[k] if( self[k].nil? || other[k].nil? )
        value ||= other[k].is_a?(Hash) && self[k].is_a?(Hash) ? (other[k] | self[k]) : [*other[k]] | [*self[k]]

        sum.update(k => value)
      end
    else
      self
    end
  end

  def deep_compact
    compact.transform_values{|vl| vl.try(:deep_compact) || vl.is_a?(Array) && vl.map{|el| el.try(:deep_compact) || el } || vl }
  end

end

Hash.include(HashExt)