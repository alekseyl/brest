module SwaggerResponses
  module NotAuthorized
    def self.extended(base)
      base.response 401 do
        key :description, 'Not authorized'
        schema type: :object do
          property :error, { type: :string }
        end
      end
    end
  end

  # humble reminder about true 403 Forbidden
  # The request contained valid data and was understood by the server, but the server is refusing action.
  # This may be due to the user not having the necessary permissions for a resource or needing an account of some sort,
  # or attempting a prohibited action (e.g. creating a duplicate record where only one is allowed). !!!
  # This code is also typically used if the request provided authentication by answering the WWW-Authenticate header field challenge,
  # but the server did not accept that authentication. The request should not be repeated.
  module Forbidden
    def self.extended(base)
      base.response 403 do
        key :description, 'Access denied'
        schema {}
      end
    end
  end

  module NoContent
    def self.extended(base)
      base.response 204 do
        key :description, 'Operation successful. No content in response needed'
        schema {}
      end
    end
  end

  module NotFound
    def self.extended(base)
      base.response 404 do
        key :description, 'Not found'
        schema {}
      end
    end
  end

  module UnprocessableEntity
    def self.extended(base)
      base.response 422 do
        key :description, 'Unprocessable Entity'
        schema type: :object do
          property :errors, type: :object do
           property :messages, type: [:object, :string]
          end
          property :data, type: :object
        end
      end
    end
  end
end