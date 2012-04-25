class CreateVars < ActiveRecord::Migration
  def change
    create_table :vars, :options => 'engine=MyISAM'  do |t|
      t.references :job
      t.string :name, :null => false
      t.text :data, :null => false, :default => ''
      t.references :action, :null => true, :default => nil
      t.references :step, :null => true, :default => nil

      t.timestamps
    end
  add_index :vars, [:job_id, :name], :unique => true
  end
end
