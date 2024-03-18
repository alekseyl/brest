require 'test_helper'

class JsonbFeaturesTest < ActiveSupport::TestCase
  test 'jsonb included as selected attribute in select scope' do
    user = User.select_sw(:User).find(identify(:frodo))
    assert_not(user.stats.blank?)
  end

  test 'jsonb will return only fields declared in defined model when as_json used with proper model' do
    jsonb_full = users(:frodo).as_json(:UserAdminView).deep_symbolize_keys
    jsonb_partial = users(:frodo).as_json(:User).deep_symbolize_keys

    assert(jsonb_full[:stats][:admin_comment].present?)
    assert(jsonb_partial[:stats][:admin_comment].blank?)
  end

  test 'jsonb array type field' do
    frodo_json = users(:frodo).as_json(:User).deep_symbolize_keys

    assert_equal( frodo_json[:stats][:preferred_items], ["mug"] )
  end
end