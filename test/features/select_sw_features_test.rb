require 'test_helper'

class SelectSwFeaturesTest < ActiveSupport::TestCase

  test "select_sw include needed and exclude not needed attributes when constructing models instance" do
    item = Item.select_sw(:ItemUpdate).find(identify(:mug))
    assert_equal(item.attributes["price"], 6.00)
    assert(item.attributes[:code].blank?)

    item_full = Item.select_sw(:Item).find(identify(:mug))
    assert_equal(item_full.code, 'mug')
  end

  test "property extension works fine with nested model definition" do
    user = User.select_sw(:User).find(identify(:frodo)).as_json(:User)

    assert_equal(user.dig("user_profile", "address"), "Hole in the middle of Shire" )
  end

  test "as_json works with clear jsonb columns" do
    item_json = items(:mug_1).as_json(:Item)
    assert_equal(item_json.dig("payload", "full_description"), "Just a beer mug")
  end

  test "select_sw works with nested model definition" do
    user_preview_json = User.includes_sw(:UserFullPreview)
                            .select_sw(:UserFullPreview)
                            .find(identify(:frodo)).as_json(:UserFullPreview)

    assert_nil( user_preview_json.dig("bought_items", 0, "payload") )

    user_full_json = User.includes_sw(:User).select_sw(:User).find(identify(:frodo)).as_json(:User)

    assert_equal( user_full_json.dig("bought_items").map{ _1.dig("payload", "short_description") }.tally,
                ["THE MUG!", "mug 1"].tally)
  end
end