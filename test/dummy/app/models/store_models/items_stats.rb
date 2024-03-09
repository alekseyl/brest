# frozen_string_literal: true

# just for the demonstration purpose only
class StoreModels::ItemsStats
  include ::StoreModel::Model

  attribute :mug, :integer
  attribute :tshirt, :integer
  attribute :hoodie, :integer
end
