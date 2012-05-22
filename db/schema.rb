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

ActiveRecord::Schema.define(:version => 20120325214219) do

  create_table "actions", :force => true do |t|
    t.integer  "job_id"
    t.integer  "step_id"
    t.integer  "errno",        :default => 0, :null => false
    t.text     "errmsg",                      :null => false
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", :force => true do |t|
    t.integer  "step_id"
    t.string   "label",        :default => "", :null => false
    t.string   "creator",      :default => "", :null => false
    t.integer  "errno",        :default => 0,  :null => false
    t.string   "errmsg",       :default => "", :null => false
    t.text     "context",                      :null => false
    t.text     "worker",                       :null => false
    t.integer  "bsid"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "links", :force => true do |t|
    t.string   "label"
    t.integer  "step_id"
    t.integer  "next_id"
    t.text     "params",                         :null => false
    t.string   "type",       :default => "Link", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "params", :force => true do |t|
    t.integer  "step_id"
    t.string   "name"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "params", ["name"], :name => "index_params_on_name"
  add_index "params", ["step_id"], :name => "index_params_on_step_id"

  create_table "steps", :force => true do |t|
    t.string   "label"
    t.text     "description"
    t.text     "params_old"
    t.string   "type",        :default => "StepNoop", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "systems", :force => true do |t|
    t.string   "label"
    t.string   "monitor_url"
    t.text     "status_json", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vars", :force => true do |t|
    t.integer  "job_id"
    t.string   "name",                          :null => false
    t.text     "data",                          :null => false
    t.integer  "action_id"
    t.integer  "step_id"
    t.boolean  "json",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vars", ["job_id", "name"], :name => "index_vars_on_job_id_and_name", :unique => true

end
