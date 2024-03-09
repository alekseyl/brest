class User < ApplicationRecord
  extend EnumExt

  attribute :stats, StoreModels::UserStats.to_type

  enum :membership, { basic: 1, silver: 2, gold: 3, platinum: 4 },
       default: :basic,
       enum_supersets: [ vip: [:gold, :platinum] ]

  validates :name, format: { with: /\A[a-zA-Z\d]+\z/ }
end