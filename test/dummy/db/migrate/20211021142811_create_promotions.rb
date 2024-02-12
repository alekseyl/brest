class CreatePromotions < ActiveRecord::Migration[6.0]
  def change
    create_table :promotions do |t|
      t.string :title, allow_nil: false
      t.boolean :active, allow_nil: false, default: true
      t.integer :discount
      t.boolean :open, allow_nil: false, default: false
      t.string :pattern, array: true, default: [], allow_nil: false
      t.string :free_stuff, array: true, default: [], allow_nil: false

      t.timestamps
    end

    add_index :promotions, :pattern, using: :gin, where: 'active'
  end
end
