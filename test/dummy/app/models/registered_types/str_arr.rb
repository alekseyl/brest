# frozen_string_literal: true

class RegisteredTypes::StrArr < ActiveRecord::Type::Value
  def type
    :str_arr
  end

  def cast(value)
    case value
    when String
      value.split(',')
    when Array
      value.map(&:to_s)
    end
  rescue ArgumentError, TypeError
    nil
  end
end

ActiveModel::Type.register(:str_arr, RegisteredTypes::StrArr)
