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

      def in_org_namespace; path_id(:org_id, "Organization numeric id") end

      def in_common_type_namespace(only_types = nil)
        parameter(name: :common_type,
          in: :path,
          description: "Выбрать неймспейс карточек",
          required: true,
          type: :string,
          enum: only_types || Card::COMMON_TYPE_NAMESPACES)
      end

      def in_common_type_namespace_taskless
        parameter(name: :common_type,
          in: :path,
          description: "Выбрать неймспейс карточек",
          required: true,
          type: :string,
          enum: Card::COMMON_TYPE_NAMESPACES - ["tasks"])
      end

      def in_task_id_namespace(route_limitation: [])
        path_id(:task_id, "Task local to space numeric id.", route_limitation)
      end

      def in_task_action_uuid_namespace; path_id(:uuid, "Task action uuid") end

      def in_space_namespace; path_id(:space_id, "Space numeric id") end

      def in_card_namespace(route_limitation: []); path_id(:card_id, "Card numeric id!", route_limitation) end

      def add_path_params(path)
        in_org_namespace     if path.match?("org/{org_id}")
        in_space_namespace   if path.match?("spaces/{space_id}")
        path_id              if path.match?("{id}")
        in_card_namespace    if path.match?("cards/{card_id}")
        in_task_id_namespace if path.match?("tasks/{task_id}")
      end
    end
  end
end
