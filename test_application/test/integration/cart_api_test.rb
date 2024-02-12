class ItemsApiTest < MiniApivoreTestBase
  
  # ----------------------------
  # Items Routes check helpers 
  # ----------------------------
  def __calc_total( expectation, ids )
    check_route( :post, '/cart/items_total.json', expectation, _data: { ids: ids })
  end

  # ----------------------------
  # Items Routes check helpers END
  # ----------------------------

  test 'Check two mugs total' do
    __calc_total(OK, identify_many(:mug, :mug))
    assert_equal( data_os.total, 6.0)
  end

  test 'Tshirts 30% for 3+' do
    __calc_total(OK, identify_many(:tshirt, :tshirt, :tshirt, :tshirt))
    assert_equal( data_os.total, 15.0 * 0.7 * 4.0  )
  end

  test 'No discount whenever conditions are not matched' do
    __calc_total(OK, identify_many(:mug, :tshirt, :tshirt, :hoodie))
    assert_equal( data_os.total, 6.0 + 15.0 + 15.0 + 20.0 )
  end

end