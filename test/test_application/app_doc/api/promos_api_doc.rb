class PromosApiDoc
  include Swagger::Blocks

  module SinglePromotionResponse
    def self.extended(base)
      base.response 200 do
        key :description, 'Single promotion info'
        response_schema do
          property :promotion, type: :object, '$ref' => :Promotion
        end
      end
    end
  end

  create_resource( path: '/promotions.json',
                   summary: 'Add new promotion to the store',
                   description: 'Add new promotion to the store',
                   tags: ['promotions'] ) do

    parameter name: '',
              in: :body,
              description: '',
              required: true do
      schema do
        property :promotion, type: :object, '$ref' => :PromotionInput
      end
    end

    extend SinglePromotionResponse
    extend SwaggerResponses::UnprocessableEntity
  end

  show_resource( path: '/promotions/{id}.json',
                   summary: 'Get single promotion attributes',
                   description: 'Get single promotion attributes by id.',
                   tags: ['promotions'] ) do

    parameter :id


    extend SinglePromotionResponse
    extend SwaggerResponses::NotFound
  end

  update_resource( path: '/promotions/{id}.json',
                   summary: 'Update existing promotion',
                   description: 'Update existing promotion',
                   tags: ['promotions'] ) do
    parameter :id

    parameter name: '',
              in: :body,
              description: '',
              required: true do
      schema do
        property :promotion, type: :object, '$ref' => :PromotionInput
      end
    end
    extend SinglePromotionResponse
    extend SwaggerResponses::UnprocessableEntity
    extend SwaggerResponses::NotFound
  end

  index_resource( path: '/promotions.json',
                  summary: 'List all promotions',
                  description: 'Paginated list of all promotions',
                  tags: ['promotions'] ) do

    parameter :page
    parameter :per_page

    response 200 do
      key :description, 'Requested promotions info'
      response_schema required: ['promotions'] do
        array :promotions, :Promotion, description: 'Promotions array'
      end
    end
  end

  delete_resource( path: '/promotions/{id}.json',
                   summary: 'Remove promotion',
                   description: 'Completely remove promotion from promotions list. You could mark in inactive if you plan to use it in future promotions',
                   tags: ['promotions']) do

    parameter :id

    extend SwaggerResponses::NotFound
    extend SwaggerResponses::NoContent
  end
end