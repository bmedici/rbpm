class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.references :step, :as => :step
      t.string :label, :null => false, :default => ''
      t.string :creator, :null => false, :default => ''
      t.references :worker
      t.integer :errno, :default => 0, :null => false
      t.string :errmsg, :null => false, :default => ''
      t.datetime :started_at, :null => true
      t.datetime :completed_at, :null => true
      t.timestamps
    end
  end
end
