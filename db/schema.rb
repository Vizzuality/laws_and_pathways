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

ActiveRecord::Schema.define(version: 2019_08_05_170751) do

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

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
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
    t.string "visibility_status", default: "draft"
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

  create_table "documents", force: :cascade do |t|
    t.string "name", null: false
    t.string "type", null: false
    t.text "external_url"
    t.string "language"
    t.date "last_verified_on"
    t.string "documentable_type"
    t.bigint "documentable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable_type_and_documentable_id"
  end

  create_table "legislations", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "law_id"
    t.string "framework"
    t.string "slug", null: false
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_passed"
    t.string "visibility_status", default: "draft"
    t.index ["location_id"], name: "index_legislations_on_location_id"
    t.index ["slug"], name: "index_legislations_on_slug", unique: true
  end

  create_table "legislations_litigations", id: false, force: :cascade do |t|
    t.bigint "litigation_id", null: false
    t.bigint "legislation_id", null: false
    t.index ["legislation_id"], name: "index_legislations_litigations_on_legislation_id"
    t.index ["litigation_id"], name: "index_legislations_litigations_on_litigation_id"
  end

  create_table "legislations_targets", force: :cascade do |t|
    t.bigint "legislation_id"
    t.bigint "target_id"
    t.index ["legislation_id"], name: "index_legislations_targets_on_legislation_id"
    t.index ["target_id", "legislation_id"], name: "index_legislations_targets_on_target_id_and_legislation_id", unique: true
    t.index ["target_id"], name: "index_legislations_targets_on_target_id"
  end

  create_table "litigation_sides", force: :cascade do |t|
    t.bigint "litigation_id"
    t.string "name"
    t.string "side_type", null: false
    t.string "party_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "connected_entity_type"
    t.bigint "connected_entity_id"
    t.index ["connected_entity_type", "connected_entity_id"], name: "index_litigation_sides_connected_entity"
    t.index ["litigation_id"], name: "index_litigation_sides_on_litigation_id"
  end

  create_table "litigations", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.string "citation_reference_number"
    t.string "document_type"
    t.bigint "location_id"
    t.bigint "jurisdiction_id"
    t.text "summary"
    t.text "core_objective"
    t.text "keywords"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "visibility_status", default: "draft"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.index ["created_by_id"], name: "index_litigations_on_created_by_id"
    t.index ["document_type"], name: "index_litigations_on_document_type"
    t.index ["jurisdiction_id"], name: "index_litigations_on_jurisdiction_id"
    t.index ["location_id"], name: "index_litigations_on_location_id"
    t.index ["slug"], name: "index_litigations_on_slug", unique: true
    t.index ["updated_by_id"], name: "index_litigations_on_updated_by_id"
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
    t.string "visibility_status", default: "draft"
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

  create_table "target_scopes", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "targets", force: :cascade do |t|
    t.bigint "location_id"
    t.bigint "sector_id"
    t.bigint "target_scope_id"
    t.boolean "ghg_target", default: false, null: false
    t.boolean "single_year", default: false, null: false
    t.text "description"
    t.integer "year"
    t.string "base_year_period"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "target_type"
    t.string "visibility_status", default: "draft"
    t.index ["location_id"], name: "index_targets_on_location_id"
    t.index ["sector_id"], name: "index_targets_on_sector_id"
    t.index ["target_scope_id"], name: "index_targets_on_target_scope_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "companies", "locations"
  add_foreign_key "companies", "locations", column: "headquarter_location_id"
  add_foreign_key "companies", "sectors"
  add_foreign_key "cp_assessments", "companies", on_delete: :cascade
  add_foreign_key "cp_benchmarks", "sectors", on_delete: :cascade
  add_foreign_key "legislations", "locations"
  add_foreign_key "legislations_targets", "legislations", on_delete: :cascade
  add_foreign_key "legislations_targets", "targets", on_delete: :cascade
  add_foreign_key "litigation_sides", "litigations", on_delete: :cascade
  add_foreign_key "litigations", "admin_users", column: "created_by_id"
  add_foreign_key "litigations", "admin_users", column: "updated_by_id"
  add_foreign_key "litigations", "locations", column: "jurisdiction_id", on_delete: :cascade
  add_foreign_key "litigations", "locations", on_delete: :cascade
  add_foreign_key "mq_assessments", "companies", on_delete: :cascade
  add_foreign_key "taggings", "tags", on_delete: :cascade
  add_foreign_key "targets", "locations"
  add_foreign_key "targets", "sectors"
  add_foreign_key "targets", "target_scopes"
end
