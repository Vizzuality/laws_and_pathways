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

ActiveRecord::Schema.define(version: 2019_07_15_092238) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.bigint "location_id"
    t.bigint "headquarter_location_id"
    t.bigint "sector_id"
    t.string "name", null: false
    t.string "slug", null: false
    t.string "isin", null: false
    t.string "size"
    t.boolean "ca100", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["headquarter_location_id"], name: "index_companies_on_headquarter_location_id"
    t.index ["isin"], name: "index_companies_on_isin", unique: true
    t.index ["location_id"], name: "index_companies_on_location_id"
    t.index ["sector_id"], name: "index_companies_on_sector_id"
    t.index ["size"], name: "index_companies_on_size"
    t.index ["slug"], name: "index_companies_on_slug", unique: true
  end

  create_table "cp_assessments", force: :cascade do |t|
    t.bigint "company_id"
    t.date "publication_date", null: false
    t.date "assessment_date"
    t.jsonb "emissions"
    t.text "assumptions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_cp_assessments_on_company_id"
  end

  create_table "cp_benchmarks", force: :cascade do |t|
    t.bigint "sector_id"
    t.date "date", null: false
    t.jsonb "benchmarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sector_id"], name: "index_cp_benchmarks_on_sector_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "location_type", null: false
    t.string "iso", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.string "region", null: false
    t.boolean "federal", default: false, null: false
    t.text "federal_details"
    t.text "approach_to_climate_change"
    t.text "legislative_process"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["iso"], name: "index_locations_on_iso", unique: true
    t.index ["region"], name: "index_locations_on_region"
    t.index ["slug"], name: "index_locations_on_slug", unique: true
  end

  create_table "mq_assessments", force: :cascade do |t|
    t.bigint "company_id"
    t.string "level", null: false
    t.text "notes"
    t.date "assessment_date", null: false
    t.date "publication_date", null: false
    t.jsonb "questions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_mq_assessments_on_company_id"
  end

  create_table "sectors", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sectors_on_name", unique: true
    t.index ["slug"], name: "index_sectors_on_slug", unique: true
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "type"], name: "index_tags_on_name_and_type", unique: true
  end

  add_foreign_key "companies", "locations"
  add_foreign_key "companies", "locations", column: "headquarter_location_id"
  add_foreign_key "companies", "sectors"
  add_foreign_key "cp_assessments", "companies", on_delete: :cascade
  add_foreign_key "cp_benchmarks", "sectors", on_delete: :cascade
  add_foreign_key "mq_assessments", "companies", on_delete: :cascade
  add_foreign_key "taggings", "tags", on_delete: :cascade
end
