class Item < ApplicationRecord
  # Rails style guided+
  #-------------------- 1. includes and extend --------------
  #-------------------- 2. default scope --------------------
  #-------------------- 3. inner classes --------------------
  #-------------------- 5. attr related macros --------------
  #-------------------- 6. enums ----------------------------
  enum code: { mug: 1, tshirt: 2, hoodie: 3 }
  #-------------------- 7. scopes ---------------------------
  scope :by_ids, -> (ids) { ids.blank? ? none : where(id: ids) }
  #-------------------- 8. has and belongs ------------------
  #-------------------- 9. accept nested macros  ------------
  #-------------------- 10. validation ----------------------
  validate :price, -> {errors.add(:price, 'Price should be positive number!') if price <= 0}
  validates_presence_of :name, :code
  #-------------------- 11. before/after callbacks ----------
  #-------------------- 12. enums related macros ------------
  #-------------------- 13. delegate macros -----------------
  #-------------------- 14. other macros (like devise's) ----
  #-------------------- should be placed after callbacks ----
  #-------------------- 15. public class methods ------------
  #-------------------- 16. instance public methods ---------
  #-------------------- 17. protected and private methods ---

end
