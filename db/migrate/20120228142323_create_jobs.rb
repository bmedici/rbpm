class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.references :step, :as => :step
      t.string :creator
      #t.references :end_step, :as => :step
      t.integer :locked, :default => nil, :null => true
      t.integer :retcode, :default => nil, :null => true
      t.datetime :started_at, :null => true
      t.datetime :completed_at, :null => true
      t.timestamps
    end
  end
end
