# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 7) do

  create_table "availabilities", force: :cascade do |t|
    t.integer "player_id"
    t.integer "playdate_id"
    t.integer "status"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["playdate_id"], name: "index_availabilities_on_playdate_id"
    t.index ["player_id"], name: "index_availabilities_on_player_id"
  end

  create_table "playdates", force: :cascade do |t|
    t.date "day"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "full_name", limit: 255
    t.string "abbreviation", limit: 255
    t.string "password_hash", limit: 255
    t.string "password_salt", limit: 255
    t.boolean "is_admin"
    t.integer "default_status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
