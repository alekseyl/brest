require 'test_helper'

class UsersApiTest < MiniApivoreTestBase
  
  # ----------------------------
  # users Routes check helpers 
  # ----------------------------

  def __get_user( id, expectation )
    check_route( :get, '/users/{id}.json', expectation, id: id)
  end

  def __create_user( expectation, params )
    check_route( :post, '/users.json', expectation, **params)
  end

  def __get_users( expectation, params )
    check_route( :get, '/users.json', expectation, **params)
  end

  def __update_user( id, expectation, params )
    check_route( :patch, '/users/{id}.json', expectation, id: id, **params)
  end
  
  def __delete_user(id, expectation)
    check_route( :delete, '/users/{id}.json', expectation, id: id )
  end

  # ----------------------------
  # users Routes check helpers END
  # ----------------------------

  test 'NOT FOUND' do
    __get_user( identify(:non_existent_fixture), NOT_FOUND )
    __update_user( identify(:non_existent_fixture), NOT_FOUND, _data: {user: {email: 'eml@mddlea.rth'}} )
    __delete_user( identify(:non_existent_fixture), NOT_FOUND )
  end

  test 'UNPROCESSABLE ENTITY for user update' do
    __update_user( identify(:frodo), UNPROCESSABLE_ENTITY, _data: {user: {name: '&^&^^&'}} )
    # we should not only match unprocessable expectations but also what did go wrong
    # to be sure, we are not shadowing other errors
    assert_equal( error_os.messages.name, ['is invalid'] )
  end

  test 'UNPROCESSABLE ENTITY for user create' do
    __create_user( UNPROCESSABLE_ENTITY, _data: {user: {name: '0--02'}} )
    # we should not only match unprocessable expectations but also what did go wrong
    # to be sure, we are not shadowing other errors
    assert_equal( error_os.messages.name, ['is invalid'] )
  end

  test 'Get users with pagination is OK' do
    ids = identify_many( :frodo, :aragorn, :sauron ).sort
    __get_users(OK, _query_string: { per_page: 1 })
    assert_equal(data_os.users.map(&:id), [ids.first] )

    __get_users(OK, _query_string: { per_page: 1, page: 1 })
    assert_equal(data_os.users.map(&:id), [ids.second] )
  end

  test 'GET single user OK' do
    frodo = users(:frodo)
    __get_user( frodo.id, OK )

    assert_equal( frodo.id, data_os.user.id )
    assert_equal( frodo.name, data_os.user.name )
    assert_equal( frodo.email, data_os.user.email )
  end

  test 'UPDATE user OK and only uses params of the UserUpdate model' do
    frodo = users(:frodo)

    assert_no_changes( -> {frodo.reload.email}, -> {frodo.reload.membership} ) {
      __update_user(frodo.id, OK, _data: { user: { name: 'Bilbo', email: 'blb@bag.io', membership: :gold } })
    }
    assert_equal( frodo.id, data_os.user.id )
    assert_equal( data_os.user.name, 'Bilbo' )
  end

  test 'CREATE user OK, again only corresponding params are used' do
    assert_difference( -> { User.count } ) {
      __create_user( OK, _data: { user: { name: 'Bilbo', email: 'blb@bag.io', membership: :gold } })
    }
    # membership param is not editable by user
    assert_equal( data_os.user.membership, 'basic' )
    assert_equal( data_os.user.email, 'blb@bag.io' )
    assert_equal( data_os.user.name, 'Bilbo' )
  end

  test 'DESTROY goes OK' do
    assert_difference( -> {User.count} => -1 ) {
      __delete_user(identify(:frodo), NO_CONTENT)
    }
  end

end