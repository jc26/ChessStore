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

ActiveRecord::Schema.define(version: 20170503013230) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "item_prices", force: :cascade do |t|
    t.integer "item_id"
    t.float   "price"
    t.string  "category"
    t.date    "start_date"
    t.date    "end_date"
  end

  add_index "item_prices", ["item_id"], name: "index_item_prices_on_item_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.string  "name"
    t.text    "description"
    t.string  "color"
    t.string  "category"
    t.float   "weight"
    t.integer "inventory_level"
    t.integer "reorder_level"
    t.boolean "active",          default: true
    t.string  "picture"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "order_id"
    t.integer "item_id"
    t.integer "quantity"
    t.date    "shipped_on"
  end

  add_index "order_items", ["item_id"], name: "index_order_items_on_item_id", using: :btree
  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.date    "date"
    t.integer "school_id"
    t.integer "user_id"
    t.float   "grand_total"
    t.string  "payment_receipt"
  end

  add_index "orders", ["school_id"], name: "index_orders_on_school_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "purchases", force: :cascade do |t|
    t.integer "item_id"
    t.integer "quantity"
    t.date    "date"
  end

  add_index "purchases", ["item_id"], name: "index_purchases_on_item_id", using: :btree

  create_table "schools", force: :cascade do |t|
    t.string  "name"
    t.string  "street_1"
    t.string  "street_2"
    t.string  "city"
    t.string  "state"
    t.string  "zip"
    t.integer "min_grade"
    t.integer "max_grade"
    t.boolean "active",    default: true
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.string   "username"
    t.string   "password_digest"
    t.string   "role",            default: "customer"
    t.boolean  "active",          default: true
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

end
