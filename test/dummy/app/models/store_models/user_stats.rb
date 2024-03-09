# frozen_string_literal: true

# just for the demonstration purpose only
class StoreModels::UserStats
  include ::StoreModel::Model

  attribute :total_money_spent, :integer
  attribute :preferred_items, type: :str_arr

  attribute :items_stats, StoreModels::ItemsStats.to_type
  attribute :admin_comment, type: :string
end
