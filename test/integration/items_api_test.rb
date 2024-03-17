require 'test_helper'

class ItemsApiTest < MiniApivoreTestBase
  
  # ----------------------------
  # Items Routes check helpers 
  # ----------------------------

  def __get_item( id, expectation )
    check_route( :get, '/items/{id}.json', expectation, id: id)
  end

  def __create_item( expectation, params )
    check_route( :post, '/items.json', expectation, **params)
  end

  def __get_items( expectation, params )
    check_route( :get, '/items.json', expectation, **params)
  end

  def __update_item( id, expectation, params )
    check_route( :patch, '/items/{id}.json', expectation, id: id, **params)
  end
  
  def __delete_item(id, expectation)
    check_route( :delete, '/items/{id}.json', expectation, id: id )
  end

  # ----------------------------
  # Items Routes check helpers END
  # ----------------------------

  test 'NOT FOUND' do
    __get_item( identify(:non_existent_fixture), NOT_FOUND )
    __update_item( identify(:non_existent_fixture), NOT_FOUND, _data: {item: {price: 10}} )
    __delete_item( identify(:non_existent_fixture), NOT_FOUND )
  end

  test 'UNPROCESSABLE ENTITY for item update' do
    __update_item( identify(:mug), UNPROCESSABLE_ENTITY, _data: {item: {price: -10}} )
    # we should not only match unprocessable expectations but also what did go wrong
    # to be sure, we are not shadowing other errors
    assert_equal( error_os.messages.price, ['Price should be positive number!'] )
  end

  test 'UNPROCESSABLE ENTITY for item CREATE' do
    __create_item( UNPROCESSABLE_ENTITY, _data: { item: { price: 99.9, code: 'tshirt' } } )
    # we should not only match unprocessable expectations but also what did go wrong
    # to be sure, we are not shadowing other errors
    assert_equal( error_os.messages.name, ["can't be blank"] )
  end

  test 'Get items with pagination is OK bb' do
    ids = identify_many( :mug, :mug_1, :tshirt, :hoodie ).sort
    __get_items(OK, _query_string: { per_page: 1 })
    assert_equal(data_os.items.map(&:id), [ids.first] )

    __get_items(OK, _query_string: { per_page: 1, page: 1 })
    assert_equal(data_os.items.map(&:id), [ids.second] )
  end

  test 'GET single item OK' do
    mug = items(:mug)
    __get_item( mug.id, OK )

    assert_equal( mug.id, data_os.item.id )
    assert_equal( mug.price, data_os.item.price )
    assert_equal( mug.name, data_os.item.name )
  end

  test 'UPDATE item OK' do
    mug = items(:mug)
    assert_no_changes( -> {mug.reload.code}, -> {mug.reload.name} ) {
      __update_item(mug.id, OK, _data: { item: { price: 99.9, name: 'MEDIUM TSHIRT :P', code: 'tshirt' } })
    }
    assert_equal( mug.id, data_os.item.id )
    assert_equal( data_os.item.code, 'mug' )
    assert_equal( data_os.item.price, 99.9 )
    assert_equal( mug.price, 99.9 )
  end

  test 'CREATE item OK' do
    assert_difference( -> { Item.count } ) {
      __create_item( OK, _data: { item: { price: 99.9, name: 'black tshirt', code: 'tshirt' } })
    }
    assert_equal( data_os.item.code, 'tshirt' )
    assert_equal( data_os.item.price, 99.9 )
    assert_equal( data_os.item.name, 'black tshirt' )
  end

  test 'DESTROY goes OK' do
    assert_difference( -> {Item.count} => -1 ) {
      __delete_item(identify(:mug), NO_CONTENT)
    }
  end

end