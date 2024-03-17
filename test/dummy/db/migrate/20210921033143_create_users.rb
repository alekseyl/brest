class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :membership, limit: 2
      t.jsonb :stats

      t.timestamps
    end

    create_table :admins do |t|
      t.string :name
      t.string :email
    end

    create_join_table :users, :items
  end
end
