module Swagger
  module Params
    def permit_sw(*attributes, keep: {}, keep_always: {} )
      reject_blank(
        permit(
          attributes.map do |v|
            if ApplicationRecord.permit_schemas[v]
              ApplicationRecord.permit_schemas[v].select{|val| !val.is_a?(Hash) || keep[val.keys.first].nil? || keep[val.keys.first] }
            else
              v
            end
          end.flatten(1)
        ),
        keep_always
      )
    end

    def sw_blank?
      values.all?{|el| (el == '' || el.nil? || el == {} ) }
    end

    # clearing blank objects from params, be very carefully about this,
    # because potentially this could block some second level clearance.
    def reject_blank(ac_params, force_to_keep = {})
      ac_params.transform_values! do |v|
        if v.is_a?(ActionController::Parameters)
          reject_blank(v, force_to_keep)
        elsif v.respond_to?(:reject)
          v.reject{|el| (el == '' || el.nil? || el == {} )}
        else
          v
        end
      end.reject!{ |k,v|  (v == '' || v.nil? || v == {} )  && !force_to_keep[k] }
    end
  end
end

ActionController::Parameters.prepend( Swagger::Params )
