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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 6) do

  create_table "availabilities", :force => true do |t|
    t.integer  "player_id"
    t.integer  "playdate_id"
    t.integer  "status"
    t.datetime "updated_at"
  end

  add_index "availabilities", ["playdate_id"], :name => "index_availabilities_on_playdate_id"
  add_index "availabilities", ["player_id"], :name => "index_availabilities_on_player_id"

  create_table "playdates", :force => true do |t|
    t.date "day"
  end

  create_table "players", :force => true do |t|
    t.string  "name"
    t.string  "full_name"
    t.string  "abbreviation"
    t.string  "password_hash"
    t.string  "password_salt"
    t.boolean "is_admin"
    t.integer "default_status"
  end

end
