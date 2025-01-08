class ItemDoc < DocBase

  swagger_schema :ItemUpdate, required: [:price],
                 description: 'Editable item schema part' do

    property :price, type: :number, description: 'Item price in euros.'
  end

  inherit_schema :ItemInput, :ItemUpdate, required: [:code, :name],
                 description: 'Input data model for items' do
    property :code, type: :string, enum: Item.codes.keys, description: <<~CODES
      'code' refers to desired item code, current item codes are limited to: <b>mug</b>, <b>tshirt</b>, <b>hoodie</b>.
    CODES
    property :name, type: :string, description: 'Item name'
  end

  inherit_schema :ItemPreview, :ItemInput, required: [:id], description: 'Item preview' do
    property :id, type: :integer, description: 'Item id'
  end

  inherit_schema :Item, :ItemPreview, required: [:id], description: 'Item full data model' do
    property :payload, type: :jsonb, '$ref' => :ItemPayload, description: 'Item payload'
  end
end