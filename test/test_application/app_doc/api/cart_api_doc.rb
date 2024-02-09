class CartApiDoc
  include Swagger::Blocks

  create_resource( path: '/cart/items_total.json',
                   summary: "Calculates items total",
                   description: "Calculates items total. All active promotions will be applied.",
                   tags: ['discount'] ) do

    parameter name: '',
              in: :body,
              description: '',
              required: true do
      schema do
        array :ids, :integer, description: 'Item ids for total calculations'
      end
    end

    response 200 do
      key :description, 'Cart total'
      response_schema( required: [:total] ) do
        property :total, type: :number, description: "Total price for a given items"
      end
    end
  end

end