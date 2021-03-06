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

ActiveRecord::Schema.define(version: 20180301200214) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "likes", force: :cascade do |t|
    t.string   "liker_type"
    t.integer  "liker_id"
    t.string   "likeable_type"
    t.integer  "likeable_id"
    t.datetime "created_at"
  end

  add_index "likes", ["likeable_id", "likeable_type"], name: "fk_likeables", using: :btree
  add_index "likes", ["liker_id", "liker_type"], name: "fk_likes", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "text"
    t.datetime "created_at"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "receiver_id",          null: false
    t.integer  "sender_id",            null: false
    t.integer  "amount",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "commission"
    t.decimal  "commission_holder_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "telegram_id"
    t.string   "telegram_username"
    t.integer  "likees_count",      default: 0
    t.integer  "likers_count",      default: 0
    t.decimal  "amount"
    t.datetime "amount_changed_at"
    t.string   "type",              default: "resident"
  end

end
