class UsersApiDoc < DocBase

  module SingleUserResponse
    def self.extended(base)
      base.response 200 do
        key :description, 'Single user info'
        response_schema( required: [:user] )do
          property :user, type: :object, '$ref' => :User
        end
      end
    end
  end

  create_resource( path: '/users.json',
                   summary: 'Add new user to the system',
                   description: 'Add new user to the system',
                   tags: ['users'] ) do


    parameter name: '',
              in: :body,
              description: '',
              required: true do
      schema do
        property :user, type: :object, '$ref' => :UserInput
      end
    end

    extend SingleUserResponse
    extend SwaggerResponses::UnprocessableEntity
  end

  show_resource( path: '/users/{id}.json',
                   summary: 'Get single user attributes',
                   description: 'Get single user attributes by id',
                   tags: ['users'] ) do

    parameter :id

    extend SingleUserResponse
    extend SwaggerResponses::NotFound
  end

  update_resource( path: '/users/{id}.json',
                   summary: 'Update existing user',
                   description: 'Update existing user. Pay attention only name is editable right now',
                   tags: ['users'] ) do

    parameter :id

    parameter name: '',
              in: :body,
              description: '',
              required: true do
      schema do
        property :user, type: :object, '$ref' => :UserUpdate
      end
    end

    extend SingleUserResponse
    extend SwaggerResponses::UnprocessableEntity
    extend SwaggerResponses::NotFound
  end

  index_resource( path: '/users.json',
                  summary: 'List system users',
                  description: 'Paginated list of users',
                  tags: ['users'] ) do

    parameter :page
    parameter :per_page

    response 200 do
      key :description, 'Requested users info'
      response_schema required: ['users'] do
        array :users, :UserPreview, description: 'Users array'
      end
    end
  end

  delete_resource( path: '/users/{id}.json',
                   summary: 'Remove user from system',
                   description: 'Completely remove user from a system.',
                   tags: ['users']) do

    parameter :id

    extend SwaggerResponses::NotFound
    extend SwaggerResponses::NoContent
  end
end