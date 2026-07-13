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

ActiveRecord::Schema[8.1].define(version: 2026_07_13_153500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_categories_on_lower_name", unique: true
    t.check_constraint "char_length(btrim(name::text)) > 0", name: "categories_name_not_blank"
  end

  create_table "tasks", force: :cascade do |t|
    t.integer "assigned_to", default: 0, null: false
    t.bigint "category_id", null: false
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.date "desired_completion_date"
    t.string "name", null: false
    t.text "notes"
    t.datetime "notified_at"
    t.integer "priority", default: 1, null: false
    t.datetime "reminder_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_tasks_on_category_id"
    t.index ["reminder_at"], name: "index_tasks_pending_reminders", where: "(notified_at IS NULL)"
    t.index ["status"], name: "index_tasks_on_status"
    t.check_constraint "char_length(btrim(name::text)) > 0", name: "tasks_name_not_blank"
  end

  add_foreign_key "tasks", "categories"
end
