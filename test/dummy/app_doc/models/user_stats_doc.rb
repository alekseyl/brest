class UserStatsDoc < DocBase

  swagger_schema :ItemsBuyingStats, description: 'Per items spent' do
    property :mug, type: :number, description: 'Spent on mugs.'
    property :tshirt, type: :number, description: 'Spent on tshirts.'
    property :hoodie, type: :number, description: 'Spent on hoodies.'
  end

  swagger_schema :UserStats, description: 'User stats jsonb model' do
    property :total_money_spent, type: :number, description: 'Total money spent by user.'
    array :preferred_items, :string, description: 'Preferred items type.'

    property :meta, '$ref' => :ItemsBuyingStats, description: "Items buying statistics"
  end

  inherit_schema :UserStatsWithHiddenAttribute, :UserStats,
                 description: 'Example of jsnob schema inheritance and usage' do
    property :admin_comment, type: :string
  end


end