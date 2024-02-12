class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.integer :code, limit: 2
      t.string :name
      t.float :price, precision: 8, scale: 2

      t.timestamps
    end
  end
end
