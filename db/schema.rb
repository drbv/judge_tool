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

ActiveRecord::Schema.define(version: 20150327192743) do

  create_table "clubs", force: :cascade do |t|
    t.string   "name"
    t.integer  "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dance_classes", force: :cascade do |t|
    t.string   "name"
    t.integer  "safety_level"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "dance_rounds", force: :cascade do |t|
    t.integer  "round_id"
    t.integer  "dance_team_id"
    t.boolean  "finished",      default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "dance_rounds", ["dance_team_id"], name: "index_dance_rounds_on_dance_team_id"
  add_index "dance_rounds", ["round_id"], name: "index_dance_rounds_on_round_id"

  create_table "dance_teams", force: :cascade do |t|
    t.integer  "dance_class_id"
    t.integer  "club_id"
    t.string   "name"
    t.integer  "startnumber"
    t.integer  "startbook_number"
    t.integer  "rank"
    t.integer  "ranking_points"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "dance_teams", ["club_id"], name: "index_dance_teams_on_club_id"

  create_table "dance_teams_dancers", id: false, force: :cascade do |t|
    t.integer "dancer_id"
    t.integer "dance_team_id"
  end

  create_table "dancers", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "age"
    t.integer  "club_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "dancers", ["club_id"], name: "index_dancers_on_club_id"

  create_table "round_types", force: :cascade do |t|
    t.string   "name"
    t.integer  "max_teams_per_round"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "rounds", force: :cascade do |t|
    t.integer  "round_type_id"
    t.integer  "dance_class_id"
    t.datetime "start_time"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "rounds", ["dance_class_id"], name: "index_rounds_on_dance_class_id"
  add_index "rounds", ["round_type_id"], name: "index_rounds_on_round_type_id"

end
