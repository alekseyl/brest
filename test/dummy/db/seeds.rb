# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Item.create( code: 'mug', name: 'White mug', price: 6.0 )
Item.create( code: 'tshirt', name: 'Smiley face tshirt', price: 15.0 )
Item.create( code: 'hoodie', name: 'Pokemon hoodie', price: 20.0 )

Promotion.create( title: '2-for-1 (MUGS)', pattern: ['mug'], free_stuff: ['mug'], open: false, active: true )
Promotion.create( title: '30% on 3 or more tshirts', pattern: %w[tshirt tshirt tshirt], discount: 30, open: true, active: true )