# frozen_string_literal: true

module Swaggerizer::Parameters
  def permit_sw(*attributes, keep: {}, keep_always: {}, add: {})
    reject_blank(
      permit(
        attributes.map do |v|
          if Swaggerizer.permit_schemas[v]
            Swaggerizer.permit_schemas[v].select do |val|
              !val.is_a?(Hash) || keep[val.keys.first].nil? || keep[val.keys.first]
            end
          else
            v
          end
        end.flatten(1)
      ).merge(add),
      keep_always
    )
  end

  def sw_blank?
    values.all? { |el| (el == "" || el.nil? || el == {}) }
  end

  # clearing blank objects from params, be very careful about this,
  # because potentially this could block some second level clearance.
  def reject_blank(ac_params, force_to_keep = {})
    ac_params.transform_values! do |v|
      if v.is_a?(ActionController::Parameters)
        reject_blank(v, force_to_keep)
      elsif v.respond_to?(:reject)
        v.reject { |el| (el == "" || el.nil? || el == {}) }
      else
        v
      end
    end.reject! { |k, v| (v == "" || v.nil? || v == {}) && !force_to_keep[k] }
  end
end
