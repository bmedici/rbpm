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

ActiveRecord::Schema.define(:version => 20120308132603) do

  create_table "actions", :force => true do |t|
    t.integer  "run_id"
    t.integer  "step_id"
    t.text     "output"
    t.integer  "retcode"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "links", :force => true do |t|
    t.string   "label"
    t.integer  "step_id"
    t.integer  "next_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "old_condition", :null => false
    t.text     "type"
    t.text     "params",        :null => false
  end

  create_table "runs", :force => true do |t|
    t.integer  "start_step_id"
    t.integer  "end_step_id"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "steps", :force => true do |t|
    t.string   "label"
    t.text     "description"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  create_table "vars", :force => true do |t|
    t.integer  "run_id"
    t.string   "name",       :null => false
    t.string   "value"
    t.integer  "action_id"
    t.integer  "step_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vars", ["run_id", "name"], :name => "index_vars_on_run_id_and_name", :unique => true

end
