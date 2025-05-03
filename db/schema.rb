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

ActiveRecord::Schema[8.0].define(version: 2025_05_03_150644) do
  create_table "exclusions", force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "excluded_team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["excluded_team_id"], name: "index_exclusions_on_excluded_team_id"
    t.index ["team_id", "excluded_team_id"], name: "index_exclusions_on_team_id_and_excluded_team_id", unique: true
    t.index ["team_id"], name: "index_exclusions_on_team_id"
  end

  create_table "rankings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "team_id", null: false
    t.integer "technical_merit"
    t.integer "commercial_merit"
    t.integer "overall_merit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_rankings_on_team_id"
    t.index ["user_id", "team_id"], name: "index_rankings_on_user_id_and_team_id", unique: true
    t.index ["user_id"], name: "index_rankings_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_teams_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.integer "user_type"
    t.integer "team_id"
    t.datetime "last_login_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["team_id"], name: "index_users_on_team_id"
  end

  add_foreign_key "exclusions", "teams"
  add_foreign_key "exclusions", "teams", column: "excluded_team_id"
  add_foreign_key "rankings", "teams"
  add_foreign_key "rankings", "users"
  add_foreign_key "users", "teams"
end
