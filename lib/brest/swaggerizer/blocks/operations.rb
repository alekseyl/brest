# frozen_string_literal: true

module Swaggerizer
  module Blocks
    module Operations
      def path_id(id_name = :id, description = "Resource id", route_limitation = [])
        limitation_notice = route_limitation.blank? ? "" : " Limited to routes: #{route_limitation.join(", ")}"
        parameter(name: id_name,
          in: :path,
          description: description + limitation_notice,
          required: true,
          type: :integer,
          format: :int64)
      end

      def path_id_or_slug(id_name, description, type = :string)
        parameter(name: id_name,
          in: :path,
          description: description,
          required: true,
          type: type)
      end

      def path_scope(id_name, description, enum)
        parameter(name: id_name,
          in: :path,
          description: description,
          required: true,
          type: :string,
          enum: enum)
      end

      def add_path_params(path)
        path_id if path.match?("{id}")
      end

    end
  end
end
