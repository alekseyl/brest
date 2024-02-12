class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  extend ::Swaggerizer::ActiveRecordSwaggerizer
  include ::Swaggerizer::AsJsonSwaggerized

  scope :paginate, -> (per_page, page = 0) {
    page == 0 ? limit(per_page) : offset( page * per_page ).limit(per_page)
  }

end
