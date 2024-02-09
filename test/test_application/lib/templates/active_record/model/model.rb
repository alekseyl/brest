<% module_namespacing do -%>
class <%= class_name %> < <%= parent_class_name.classify %>

# Rails style guided+
  #-------------------- 1. includes and extend --------------
  #-------------------- 2. default scope --------------------
  #-------------------- 3. inner classes --------------------
  #-------------------- 5. attr related macros --------------
  #-------------------- 6. enums ----------------------------
  #-------------------- 7. scopes ---------------------------
  #-------------------- 8. has and belongs ------------------

<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %><%= ', polymorphic: true' if attribute.polymorphic? %><%= ', required: true' if attribute.required? %>
<% end -%>

<% attributes.select(&:token?).each do |attribute| -%>
  has_secure_token<% if attribute.name != "token" %> :<%= attribute.name %><% end %>
<% end -%>

<% if attributes.any?(&:password_digest?) -%>
has_secure_password
<% end -%>

  #-------------------- 9. accept nested macros  ------------
  #-------------------- 10. validation ----------------------
  #-------------------- 11. before/after callbacks ----------
  # 3.1 Creating an Object
  # before_validation
  # after_validation
  # before_save
  # around_save
  # before_create
  # around_create
  # after_create
  # after_save
  # after_commit / after_rollback

  # 3.2 Updating an Object
  # before_validation
  # after_validation
  # before_save
  # around_save
  # before_update
  # around_update
  # after_update
  # after_save
  # after_commit / after_rollback

  # 3.3 Destroying an Object
  # before_destroy
  # around_destroy
  # after_destroy
  # after_commit / after_rollback
  #-------------------- 12. enums related macros ------------
  #-------------------- 13. delegate macros -----------------
  #-------------------- 14. other macros (like devise's) ----
  #-------------------- should be placed after callbacks ----
  #-------------------- 15. public class methods ------------
  #-------------------- 16. instance public methods ---------
  #-------------------- 17. protected and private methods ---

end
<% end -%>
