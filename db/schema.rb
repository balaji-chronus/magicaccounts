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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140115172058) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.string   "status"
    t.text     "remarks"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "group_id"
    t.integer  "user_id"
  end

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "token"
  end

  create_table "comments", :force => true do |t|
    t.string   "activity"
    t.text     "content"
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "contacts", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "code"
  end

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "transactions", :force => true do |t|
    t.datetime "txndate"
    t.integer  "account_id"
    t.integer  "user_id"
    t.decimal  "amount",                           :precision => 14, :scale => 2
    t.string   "category"
    t.text     "remarks"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.string   "enteredby"
    t.integer  "transaction_type"
    t.integer  "group_id"
    t.string   "actors",           :limit => 2048
  end

  add_index "transactions", ["account_id"], :name => "fk_transactions_account_id"
  add_index "transactions", ["user_id"], :name => "fk_transactions_user_id"

  create_table "transactions_beneficiaries", :id => false, :force => true do |t|
    t.integer  "id",                                            :default => 0, :null => false
    t.datetime "txndate"
    t.integer  "group_id"
    t.integer  "user_id"
    t.decimal  "amount",         :precision => 14, :scale => 2
    t.string   "category"
    t.text     "remarks"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.string   "enteredby"
    t.integer  "beneficiary_id"
  end

  create_table "transactions_users", :force => true do |t|
    t.integer  "transaction_id"
    t.integer  "user_id"
    t.decimal  "amount",         :precision => 14, :scale => 2
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.decimal  "amount_paid",    :precision => 14, :scale => 2, :default => 0.0
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "email"
    t.string   "phone"
    t.text     "address"
    t.string   "company"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "user_type"
    t.string   "invite_status",   :default => "not_registered"
  end

end
