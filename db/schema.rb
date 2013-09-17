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

ActiveRecord::Schema.define(version: 20130916152915) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: true do |t|
    t.string   "address_line1"
    t.string   "locality"
    t.string   "city"
    t.string   "state"
    t.integer  "pin"
    t.string   "country"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "user_id"
    t.string   "landmark"
  end

  create_table "books", force: true do |t|
    t.string   "isbn"
    t.string   "book_name"
    t.string   "author"
    t.string   "language"
    t.string   "genre"
    t.string   "version"
    t.string   "edition"
    t.string   "publisher"
    t.integer  "pages"
    t.integer  "mrp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chats", force: true do |t|
    t.integer  "transaction_id"
    t.integer  "from_user"
    t.string   "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversations", force: true do |t|
    t.string   "subject",    default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "inventories", force: true do |t|
    t.integer  "user_id"
    t.integer  "book_id"
    t.float    "rental_price"
    t.integer  "available_in_city"
    t.string   "status"
    t.float    "commission"
    t.integer  "no_of_borrows"
    t.datetime "upload_date"
    t.string   "condition_of_book"
    t.boolean  "book_deleted"
    t.datetime "deleted_date"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "locations", force: true do |t|
    t.string   "area"
    t.string   "city"
    t.string   "state"
    t.string   "pincode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: true do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              default: ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                default: false
    t.datetime "updated_at",                           null: false
    t.datetime "created_at",                           null: false
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "notification_code"
    t.string   "attachment"
    t.boolean  "global",               default: false
    t.datetime "expires"
  end

  add_index "notifications", ["conversation_id"], name: "index_notifications_on_conversation_id", using: :btree

  create_table "profiles", force: true do |t|
    t.string   "user_first_name"
    t.string   "user_last_name"
    t.date     "DoB"
    t.string   "gender"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "user_id"
    t.string   "profile_status"
    t.string   "user_phone_no"
    t.datetime "last_update"
    t.boolean  "contact_via_sms"
    t.boolean  "delivery"
  end

  create_table "receipts", force: true do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                            null: false
    t.boolean  "is_read",                    default: false
    t.boolean  "trashed",                    default: false
    t.boolean  "deleted",                    default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "receipts", ["notification_id"], name: "index_receipts_on_notification_id", using: :btree

  create_table "transactions", force: true do |t|
    t.integer  "borrower_id"
    t.integer  "lender_id"
    t.integer  "inventory_id"
    t.string   "status"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.datetime "request_date"
    t.datetime "acceptance_date"
    t.datetime "dispatch_date"
    t.datetime "received_date"
    t.integer  "borrow_duration"
    t.integer  "renewal_count"
    t.datetime "returned_date"
    t.string   "return_pickup_date"
    t.datetime "return_received_date"
    t.date     "book_condition"
    t.float    "total_commission"
    t.datetime "rejection_date"
    t.string   "rejection_reason"
    t.string   "accept_pickup_date"
    t.string   "lender_feedback"
    t.string   "lender_comments"
    t.string   "borrower_feedback"
    t.string   "borrower_comments"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "provider"
    t.string   "uid"
    t.integer  "roles_mask",             default: 4,  null: false
    t.string   "current_status"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "will_filter_filters", force: true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "data"
    t.integer  "user_id"
    t.string   "model_class_name"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "will_filter_filters", ["user_id"], name: "index_will_filter_filters_on_user_id", using: :btree

end
