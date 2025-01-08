# frozen_string_literal: true

# just for the demonstration purpose only
class StoreModels::ItemPayload
  include ::StoreModel::Model

  # html based description
  attribute :full_description, :string
  attribute :short_description, :string
end
