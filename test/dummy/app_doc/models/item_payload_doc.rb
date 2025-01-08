class ItemPayloadDoc < DocBase

  swagger_schema :ItemPayload, description: 'Item descriptions and other ' do
    property :full_description, type: :string, description: 'full html description of the item'
    property :short_description, type: :string, description: 'short html description of the item'
  end

end