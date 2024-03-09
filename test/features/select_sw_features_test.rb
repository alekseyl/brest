require 'test_helper'

class SelectSwFeaturesTest < ActiveSupport::TestCase

  test 'select_sw include needed and exclude not needed attributes when constructing models instance' do
    item = Item.select_sw(:ItemUpdate).find(identify(:mug))
    assert_equal(item.attributes["price"], 6.00)
    assert(item.attributes[:code].blank?)

    item_full = Item.select_sw(:Item).find(identify(:mug))
    assert_equal(item_full.code, 'mug')
  end

end