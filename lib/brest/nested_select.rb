
module NestedSelect
  extend ActiveSupport::Autoload

  autoload :Relation, "brest/nested_select/relation"
  autoload :Preloader, "brest/nested_select/preloader"

  ActiveRecord::Relation.prepend(Relation)
  ActiveRecord::Associations::Preloader.include(Preloader)
end