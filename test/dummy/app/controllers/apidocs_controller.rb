class ApidocsController < ActionController::Base
  include Swagger::Blocks

  swagger_root(
      swagger: '2.0',
      host:  Rails.application.config.default_url_options.slice(:host, :port).values.join(':'),
      basePath: '/',
      consumes: ['application/json'],
      produces: ['application/json'],
      info: {
          version: '1.0.0',
          title: 'Store API',
          description: 'Store api for SPA and mobile.',
          contact: { name: 'leshchuk@gmail.com' },
          license: { name: 'MIT'}
      }
  ) do

    # reusable params
    parameter :id, name: :id,
              in: :path,
              description: 'ID of resource to take action on',
              required: true,
              type: :integer,
              format: :int64

    parameter :page, name: :page,
              in: :query,
              description: 'Screen/page number for a feed/pagination',
              required: false,
              type: :integer,
              format: :int32

    parameter :per_page, name: :per_page,
              in: :query,
              description: 'Amount of items to show per page',
              required: false,
              type: :integer,
              format: :int32

    parameter :ids, name: :ids, in: :query, required: false, type: :string, description: 'Comma separated ids to get'

  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
    ItemDoc,
    UserDoc,
    UserProfileDoc,
    UserStatsDoc,
    ItemsApiDoc,
    UsersApiDoc,
    self,
  ].freeze

  def self.build_schema
    Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end

  def index
    render json: self.class.build_schema
  end

end

