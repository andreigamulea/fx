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

ActiveRecord::Schema[7.1].define(version: 2024_12_12_134610) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "btcs", force: :cascade do |t|
    t.date "date", null: false
    t.time "timestamp", null: false
    t.decimal "open", precision: 15, scale: 6, null: false
    t.decimal "high", precision: 15, scale: 6, null: false
    t.decimal "low", precision: 15, scale: 6, null: false
    t.decimal "close", precision: 15, scale: 6, null: false
    t.decimal "volume", precision: 15, scale: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date", "timestamp"], name: "index_btcs_on_date_and_timestamp"
    t.index ["date"], name: "index_btcs_on_date"
    t.index ["timestamp"], name: "index_btcs_on_timestamp"
  end

  create_table "us30s", force: :cascade do |t|
    t.date "date", null: false
    t.time "timestamp", null: false
    t.decimal "open", precision: 15, scale: 6, null: false
    t.decimal "high", precision: 15, scale: 6, null: false
    t.decimal "low", precision: 15, scale: 6, null: false
    t.decimal "close", precision: 15, scale: 6, null: false
    t.decimal "volume", precision: 15, scale: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date", "timestamp"], name: "index_us30s_on_date_and_timestamp"
  end

  create_table "xauusds", force: :cascade do |t|
    t.date "date", null: false
    t.time "timestamp", null: false
    t.decimal "open", precision: 15, scale: 6, null: false
    t.decimal "high", precision: 15, scale: 6, null: false
    t.decimal "low", precision: 15, scale: 6, null: false
    t.decimal "close", precision: 15, scale: 6, null: false
    t.decimal "volume", precision: 15, scale: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date", "timestamp"], name: "index_xauusds_on_date_and_timestamp"
  end

end
