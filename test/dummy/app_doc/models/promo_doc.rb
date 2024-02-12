class PromoDoc < DocBase

  swagger_schema :PromotionInput, required: [:active, :open, :pattern, :title],
                 description: 'Promo creation and update attributes' do

    property :title, type: :string, description: 'Promotion title'
    array :pattern, :string, enum: Item.codes.keys, description: <<~PATTERN
      This is a promotion pattern. It based on the items codes. Pattern could be open or closed. <br/><br/>
      <b>Free stuff promo example</b>: buy tshirt and hoodie and get mug for free. <br/><br/>
      So then combination for pattern will be: [tshirt, hoodie], and 'open' will be set to FALSE, and free_stuff should be [mug].<br/><br/>

      <b>Discount promo example</b>: we want promote 3+ tshirts for a 30% discount. Pattern -- [tshirt, tshirt, tshirt], open - true, discount - 30,
      so everything what matches the pattern will get a 30% discount, in this case it will be tshirt >= 3. <br/><br/>
      
      PAY ATTENTION: you should not overlap active promotions patterns, because there will be too complicated applying logic, <br/><br/>
      and everybody would suffer starting from confused customers and engineers supporting that solution.<br/>
    PATTERN

    property :open, type: :boolean, description: 'This is pattern open state flag.'

    property :active, type: :boolean, description: 'Active promotion flag. Whenever you want to run given promotion, just set this flag to true'

    property :discount, type: [:integer, :null], description: 'Promotion percent discount. All items with codes matched to promotion'\
                                                              ' pattern will be discounted by given discount percent. Should be between 0 and 100'

    # t.string :free_stuff, array: true, default: [], allow_nil: false
    array :free_stuff, :string, enum: Item.codes.keys, description: <<~FREE_STUFF
      This is a 'BUY something' and 'get additional free_stuff' promotions rewards definition. 
      Everything mentioned in a free_stuff attribute will be not counted whenever pattern matched.
    FREE_STUFF
  end

  inherit_schema :Promotion, :PromotionInput, required: [:id], description: 'Full promo model ' do
    property :id, type: :integer, description: 'Promo id'
  end
end