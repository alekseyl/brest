class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :membership, limit: 2
      t.jsonb :stats

      t.timestamps
    end

    create_table :user_profiles do |t|
      t.string :address
      t.string :zip_code
      t.string :bio

      t.references :user
    end

    create_table :avatars do |t|
      t.string :img_url

      t.references :user_profile
    end

    create_table :admins do |t|
      t.string :name
      t.string :email
    end

    create_join_table :users, :items
  end
end
