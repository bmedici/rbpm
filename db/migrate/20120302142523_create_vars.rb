class CreateVars < ActiveRecord::Migration
  def change
    create_table :vars do |t|
      t.references :run
      t.string :name, :null => false
      t.string :value, :null => true
      t.references :action, :null => true, :default => nil
      t.references :step, :null => true, :default => nil

      t.timestamps
    end
  add_index :vars, [:run_id, :name], :unique => true
  end
end
