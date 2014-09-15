# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140911210730) do

  create_table "accounts", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ad_groups", force: true do |t|
    t.integer  "campaing_id"
    t.string   "name"
    t.integer  "amount"
    t.integer  "gr_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adword_texts", force: true do |t|
    t.integer  "group_id"
    t.string   "name"
    t.string   "name_gr"
    t.string   "amount"
    t.string   "ad_desc1"
    t.string   "ad_desc2"
    t.text     "ad_url"
    t.string   "ad_display"
    t.integer  "adw_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaings", force: true do |t|
    t.string   "camp_name"
    t.string   "bud_name"
    t.integer  "camp_id"
    t.integer  "bud_id"
    t.integer  "bud_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keywords", force: true do |t|
    t.integer  "ad_group_id"
    t.text     "keywords"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "welcomes", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
