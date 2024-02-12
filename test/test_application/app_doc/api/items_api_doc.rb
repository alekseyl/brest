class ItemsApiDoc < DocBase

  module SingleItemResponse
    def self.extended(base)
      base.response 200 do
        key :description, 'Single item info'
        response_schema( required: [:item] )do
          property :item, type: :object, '$ref' => :Item
        end
      end
    end
  end

  create_resource( path: '/items.json',
                   summary: 'Add new item to the store',
                   description: 'Add new item to the store',
                   tags: ['items'] ) do


    parameter name: '',
              in: :body,
              description: '',
              required: true do
      schema do
        property :item, type: :object, '$ref' => :ItemInput
      end
    end

    extend SingleItemResponse
    extend SwaggerResponses::UnprocessableEntity
  end

  show_resource( path: '/items/{id}.json',
                   summary: 'Get single item attributes',
                   description: 'Get single item attributes by id',
                   tags: ['items'] ) do

    parameter :id

    extend SingleItemResponse
    extend SwaggerResponses::NotFound
  end

  update_resource( path: '/items/{id}.json',
                   summary: 'Update existing item in the store',
                   description: 'Update existing item in the store. Pay attention only price is editable right now',
                   tags: ['items'] ) do

    parameter :id

    parameter name: '',
              in: :body,
              description: '',
              required: true do
      schema do
        property :item, type: :object, '$ref' => :ItemUpdate
      end
    end

    extend SingleItemResponse
    extend SwaggerResponses::UnprocessableEntity
    extend SwaggerResponses::NotFound
  end

  index_resource( path: '/items.json',
                  summary: 'List store items',
                  description: 'Paginated list of store items',
                  tags: ['items'] ) do

    parameter :page
    parameter :per_page

    response 200 do
      key :description, 'Requested items info'
      response_schema required: ['items'] do
        array :items, :Item, description: 'Items array'
      end
    end
  end

  delete_resource( path: '/items/{id}.json',
                   summary: 'Remove item from store',
                   description: 'Completely remove item from a store. '\
                                'Pay attention all later cart requests with any od deleted items will be unprocessable',
                   tags: ['items']) do

    parameter :id

    extend SwaggerResponses::NotFound
    extend SwaggerResponses::NoContent
  end
end