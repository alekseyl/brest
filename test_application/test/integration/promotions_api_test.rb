require 'test_helper'

class PromotionApiTest < MiniApivoreTestBase
  
  # ----------------------------
  # Promotions Routes check helpers 
  # ----------------------------
  def __get_promotion( id, expectation )
    check_route( :get, '/promotions/{id}.json', expectation, id: id)
  end

  def __create_promotion( expectation, params )
    check_route( :post, '/promotions.json', expectation, params)
  end

  def __get_promotions( expectation, params )
    check_route( :get, '/promotions.json', expectation, params)
  end

  def __update_promotion( id, expectation, params )
    check_route( :patch, '/promotions/{id}.json', expectation, id: id, **params)
  end
  
  def __delete_promotion(id, expectation)
    check_route( :delete, '/promotions/{id}.json', expectation, id: id )
  end
  # ----------------------------
  # Promotions Routes check helpers END
  # ----------------------------

  test 'NOT FOUND' do
    __get_promotion( identify(:non_existent_fixture), NOT_FOUND )
    __update_promotion( identify(:non_existent_fixture), NOT_FOUND, _data: {promotion: {active: true}} )
    __delete_promotion( identify(:non_existent_fixture), NOT_FOUND )
  end

  test 'UNPROCESSABLE ENTITY for promotion update' do
    __update_promotion( identify(:two_for_one), UNPROCESSABLE_ENTITY, _data: {promotion: {discount: 130}} )
    assert_equal( error_os.messages.discount, ["Discount can't be greater than 99%"])
  end

  test 'UNPROCESSABLE ENTITY for promotion CREATE' do
    __create_promotion( UNPROCESSABLE_ENTITY,
                        _data: { promotion: { title: 'Broken promo',
                                              pattern: %w[mug mug],
                                              discount: -10} } )
    # we should not only match unprocesable expectations but also what did go wrong
    # to be sure, we are not shadowing other errors
    assert_equal( error_os.messages.discount, ['Negative discounts incorrect! Use positive integer less than 100'] )
  end

  test 'Get promotions with pagination is OK' do
    ids = identify_many( :two_for_one, :tshirts, :double_three  ).sort.reverse
    __get_promotions(OK, _query_string: { per_page: 1 })
    assert_equal(data_os.promotions.map(&:id), [ids.first] )

    __get_promotions(OK, _query_string: { per_page: 1, page: 1 })
    assert_equal(data_os.promotions.map(&:id), [ids.second] )
  end

  test 'GET single promotion OK' do
    promo = promotions(:two_for_one)
    __get_promotion( promo.id, OK )

    assert_equal( promo.id, data_os.promotion.id )
    assert_equal( data_os.promotion.pattern, ['mug'] )
    assert_equal( data_os.promotion.free_stuff, ['mug'] )
    assert_equal( data_os.promotion.title, '2-for-1' )
  end

  test 'UPDATE promotion OK' do
    promo = promotions(:two_for_one)
    assert_changes( -> {promo.reload.title}, -> {promo.reload.free_stuff} ) {
      __update_promotion(promo.id, OK, _data: { promotion: { title: 'new Promotion', free_stuff: ['tshirt'] } })
    }
    assert_equal( promo.id, data_os.promotion.id )
    assert_equal( data_os.promotion.title, 'new Promotion' )
    assert_equal( data_os.promotion.free_stuff, ['tshirt'] )
  end

  test 'CREATE promotion OK' do
    assert_difference( -> {Promotion.count} ) {
      __create_promotion( OK, _data: { promotion: {
        title: 'Buy tshirt, get mug for free', pattern: ['tshirt'], free_stuff: ['mug'], open: false, active: false
      } })
    }
    assert_equal( data_os.promotion.title, 'Buy tshirt, get mug for free' )
    assert_equal( data_os.promotion.pattern, ['tshirt'] )
    assert_equal( data_os.promotion.free_stuff, ['mug'] )
  end

  test 'DESTROY goes OK' do
    assert_difference( -> {Promotion.count} => -1 ) {
      __delete_promotion(identify(:two_for_one), NO_CONTENT)
    }
  end

end