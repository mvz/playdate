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

ActiveRecord::Schema[8.1].define(version: 9) do
  create_table "availabilities", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "playdate_id"
    t.integer "player_id"
    t.integer "status"
    t.datetime "updated_at", precision: nil
    t.index ["playdate_id"], name: "index_availabilities_on_playdate_id"
    t.index ["player_id", "playdate_id"], name: "index_availabilities_on_player_id_and_playdate_id", unique: true
    t.index ["player_id"], name: "index_availabilities_on_player_id"
  end

  create_table "playdates", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.date "day"
    t.datetime "updated_at", precision: nil
    t.index ["day"], name: "index_playdates_on_day", unique: true
  end

  create_table "players", force: :cascade do |t|
    t.string "abbreviation", limit: 255
    t.datetime "created_at", precision: nil
    t.integer "default_status"
    t.string "full_name", limit: 255
    t.boolean "is_admin", null: false
    t.string "name", limit: 255
    t.string "password_hash", limit: 255
    t.string "password_salt", limit: 255
    t.datetime "updated_at", precision: nil
    t.index ["name"], name: "index_players_on_name", unique: true
  end
end
