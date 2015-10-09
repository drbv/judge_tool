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

ActiveRecord::Schema.define(version: 20150922210914) do

  create_table "acrobatic_rating_history_entries", force: :cascade do |t|
    t.integer  "rating",              default: 0
    t.string   "mistakes"
    t.boolean  "danced",              default: false
    t.integer  "reopened",            default: 0
    t.integer  "acrobatic_rating_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "acrobatic_rating_history_entries", ["acrobatic_rating_id"], name: "index_acrobatic_rating_history_entries_on_acrobatic_rating_id"

  create_table "acrobatic_ratings", force: :cascade do |t|
    t.integer  "rating",        default: 0
    t.string   "mistakes"
    t.boolean  "danced",        default: false
    t.integer  "acrobatic_id"
    t.integer  "dance_team_id"
    t.integer  "user_id"
    t.integer  "reopened",      default: 0
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "acrobatic_ratings", ["acrobatic_id"], name: "index_acrobatic_ratings_on_acrobatic_id"
  add_index "acrobatic_ratings", ["dance_team_id"], name: "index_acrobatic_ratings_on_dance_team_id"
  add_index "acrobatic_ratings", ["user_id", "acrobatic_id", "reopened"], name: "reopened_user_acrobatic"
  add_index "acrobatic_ratings", ["user_id", "acrobatic_id"], name: "index_acrobatic_ratings_on_user_id_and_acrobatic_id"
  add_index "acrobatic_ratings", ["user_id"], name: "index_acrobatic_ratings_on_user_id"

  create_table "acrobatic_types", force: :cascade do |t|
    t.string   "name"
    t.string   "short_name"
    t.decimal  "max_points",   precision: 2, scale: 2
    t.integer  "saftey_level"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "acrobatics", force: :cascade do |t|
    t.integer  "dance_team_id"
    t.integer  "dance_round_id"
    t.integer  "acrobatic_type_id"
    t.integer  "position"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "repeated",              default: false
    t.boolean  "repeating",             default: false
    t.integer  "repeated_acrobatic_id"
  end

  add_index "acrobatics", ["acrobatic_type_id"], name: "index_acrobatics_on_acrobatic_type_id"
  add_index "acrobatics", ["dance_round_id"], name: "index_acrobatics_on_dance_round_id"
  add_index "acrobatics", ["dance_team_id"], name: "index_acrobatics_on_dance_team_id"
  add_index "acrobatics", ["repeated_acrobatic_id"], name: "index_acrobatics_on_repeated_acrobatic_id"

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

  create_table "dance_rating_history_entries", force: :cascade do |t|
    t.integer  "female_base_rating",       default: 0
    t.integer  "female_turn_rating",       default: 0
    t.integer  "male_base_rating",         default: 0
    t.integer  "male_turn_rating",         default: 0
    t.integer  "choreo_rating",            default: 0
    t.integer  "dance_figure_rating",      default: 0
    t.integer  "team_presentation_rating", default: 0
    t.string   "mistakes"
    t.integer  "reopened",                 default: 0
    t.boolean  "final",                    default: false
    t.integer  "dance_rating_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "dance_rating_history_entries", ["dance_rating_id"], name: "index_dance_rating_history_entries_on_dance_rating_id"

  create_table "dance_ratings", force: :cascade do |t|
    t.integer  "female_base_rating",       default: 0
    t.integer  "female_turn_rating",       default: 0
    t.integer  "male_base_rating",         default: 0
    t.integer  "male_turn_rating",         default: 0
    t.integer  "choreo_rating",            default: 0
    t.integer  "dance_figure_rating",      default: 0
    t.integer  "team_presentation_rating", default: 0
    t.string   "mistakes"
    t.integer  "reopened",                 default: 0
    t.integer  "dance_team_id"
    t.integer  "dance_round_id"
    t.integer  "user_id"
    t.boolean  "final",                    default: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "dance_ratings", ["dance_round_id", "dance_team_id"], name: "find_by_round_and_dance_team"
  add_index "dance_ratings", ["dance_round_id", "user_id", "dance_team_id"], name: "find_by_round_and_observer_and_dance_team"
  add_index "dance_ratings", ["dance_round_id", "user_id", "reopened"], name: "find_by_judge_and_dance_round_and_reopened"
  add_index "dance_ratings", ["dance_round_id", "user_id"], name: "find_by_judge_and_dance_round"
  add_index "dance_ratings", ["dance_round_id"], name: "index_dance_ratings_on_dance_round_id"
  add_index "dance_ratings", ["dance_team_id"], name: "index_dance_ratings_on_dance_team_id"
  add_index "dance_ratings", ["user_id"], name: "index_dance_ratings_on_user_id"

  create_table "dance_round_mappings", force: :cascade do |t|
    t.integer "dance_round_id"
    t.integer "dance_team_id"
    t.integer "user_id"
    t.boolean "repeated",            default: false
    t.boolean "repeating",           default: false
    t.integer "repeated_mapping_id"
  end

  add_index "dance_round_mappings", ["dance_round_id", "dance_team_id", "user_id"], name: "observer_dance_team_mapping"
  add_index "dance_round_mappings", ["dance_round_id", "dance_team_id"], name: "dance_round_dance_team_mapping"
  add_index "dance_round_mappings", ["repeated_mapping_id"], name: "index_dance_round_mappings_on_repeated_mapping_id"

  create_table "dance_rounds", force: :cascade do |t|
    t.integer  "round_id"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.boolean  "started",     default: false
    t.boolean  "finished",    default: false
    t.integer  "position"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "dance_rounds", ["finished", "started"], name: "index_dance_rounds_on_finished_and_started"
  add_index "dance_rounds", ["position"], name: "index_dance_rounds_on_position"
  add_index "dance_rounds", ["round_id"], name: "index_dance_rounds_on_round_id"

  create_table "dance_teams", force: :cascade do |t|
    t.integer  "dance_class_id"
    t.integer  "club_id"
    t.string   "name"
    t.integer  "startnumber"
    t.integer  "startbook_number"
    t.integer  "rank"
    t.decimal  "ranking_points",   precision: 12, scale: 10
    t.integer  "access_db_id"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "dance_teams", ["club_id"], name: "index_dance_teams_on_club_id"
  add_index "dance_teams", ["startnumber"], name: "index_dance_teams_on_startnumber"

  create_table "dance_teams_dancers", id: false, force: :cascade do |t|
    t.integer "dancer_id"
    t.integer "dance_team_id"
  end

  create_table "dancers", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], name: "index_roles_on_name"

  create_table "round_types", force: :cascade do |t|
    t.string   "name"
    t.string   "acrobatics_from"
    t.boolean  "no_dance",        default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "rounds", force: :cascade do |t|
    t.integer  "round_type_id"
    t.integer  "dance_class_id"
    t.boolean  "closed",         default: false
    t.boolean  "started",        default: false
    t.integer  "max_teams"
    t.datetime "start_time"
    t.integer  "position"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "rounds", ["dance_class_id"], name: "index_rounds_on_dance_class_id"
  add_index "rounds", ["position"], name: "index_rounds_on_position"
  add_index "rounds", ["round_type_id"], name: "index_rounds_on_round_type_id"
  add_index "rounds", ["start_time"], name: "index_rounds_on_start_time"
  add_index "rounds", ["started", "closed"], name: "index_rounds_on_started_and_closed"

  create_table "users", force: :cascade do |t|
    t.string   "login"
    t.integer  "licence"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "pin"
    t.string   "name"
    t.integer  "club_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "users", ["club_id"], name: "index_users_on_club_id"
  add_index "users", ["login"], name: "index_users_on_login"

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"

end
