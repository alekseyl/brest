# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2021_10_21_033143) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "name"
    t.string "email"
  end

  create_table "avatars", force: :cascade do |t|
    t.string "img_url"
    t.bigint "user_profile_id"
    t.index ["user_profile_id"], name: "index_avatars_on_user_profile_id"
  end

  create_table "items", force: :cascade do |t|
    t.integer "code", limit: 2
    t.string "name"
    t.float "price"
    t.jsonb "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "item_id", null: false
  end

  create_table "user_profiles", force: :cascade do |t|
    t.string "address"
    t.string "zip_code"
    t.string "bio"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.integer "membership", limit: 2
    t.jsonb "stats"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
