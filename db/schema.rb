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

ActiveRecord::Schema.define(:version => 20110515091743) do

  create_table "config_vars", :force => true do |t|
    t.string "name",  :null => false
    t.binary "value", :null => false
  end

  add_index "config_vars", ["name"], :name => "index_config_vars_on_name", :unique => true

  create_table "papers", :force => true do |t|
    t.string   "name",               :null => false
    t.string   "layout_name",        :null => false
    t.float    "layout_width",       :null => false
    t.float    "layout_height",      :null => false
    t.float    "margin_top",         :null => false
    t.float    "margin_bottom",      :null => false
    t.float    "margin_left",        :null => false
    t.float    "margin_right",       :null => false
    t.float    "cell_size",          :null => false
    t.float    "group_spacing",      :null => false
    t.integer  "group_rows",         :null => false
    t.integer  "horizontal_guides",  :null => false
    t.integer  "vertical_guides",    :null => false
    t.boolean  "diagonal_guides",    :null => false
    t.float    "cell_stroke_size",   :null => false
    t.float    "guide_stroke_size",  :null => false
    t.string   "cell_stroke_color",  :null => false
    t.string   "guide_stroke_color", :null => false
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "papers", ["name"], :name => "index_papers_on_name", :unique => true

end
