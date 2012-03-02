class CreateVars < ActiveRecord::Migration
  def change
    create_table :vars do |t|
      t.references :run
      t.references :action, :null => true, :default => nil
      t.references :step, :null => true, :default => nil
      t.string :name, :null => false
      t.string :value, :null => true

      t.timestamps
    end
  end
end
