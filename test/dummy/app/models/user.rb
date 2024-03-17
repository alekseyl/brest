class User < ApplicationRecord
  # Rails style guided+
  #-------------------- 1. includes and extend --------------
  extend EnumExt
  #-------------------- 2. default scope --------------------
  #-------------------- 3. inner classes --------------------
  #-------------------- 5. attr related macros --------------
  attribute :stats, StoreModels::UserStats.to_type
  #-------------------- 6. enums ----------------------------
  enum :membership, { basic: 1, silver: 2, gold: 3, platinum: 4 },
       default: :basic,
       enum_supersets: [ vip: [:gold, :platinum] ]
  #-------------------- 7. scopes ---------------------------
  #-------------------- 8. has and belongs ------------------
  has_and_belongs_to_many :bought_items, class_name: :Item, join_table: :items_users
  #-------------------- 9. accept nested macros  ------------
  #-------------------- 10. validation ----------------------
  validates :name, format: { with: /\A[a-zA-Z\d]+\z/ }
  #-------------------- 11. before/after callbacks ----------
  #-------------------- 12. enums related macros ------------
  #-------------------- 13. delegate macros -----------------
  #-------------------- 14. other macros (like devise's) ----
  #-------------------- should be placed after callbacks ----
  #-------------------- 15. public class methods ------------
  #-------------------- 16. instance public methods ---------
  #-------------------- 17. protected and private methods ---
end