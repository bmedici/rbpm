class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs, :options => 'engine=MyISAM'  do |t|
      t.references :step, :as => :step
      t.string :label, :null => false, :default => ''
      t.string :creator, :null => false, :default => ''
      t.integer :errno, :default => 0, :null => false
      t.string :errmsg, :null => false, :default => ''
      t.text :context, :null => false, :default => ''
      t.text :worker, :null => false, :default => ''
      t.integer :bsid, :null => true, :default => nil

      t.datetime :started_at, :null => true
      t.datetime :completed_at, :null => true
      t.timestamps
    end
  end
end
