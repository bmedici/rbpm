class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :label
      t.references :step
      t.references :next
      t.text :params, :null => false
      t.string :type, :null => true
      t.timestamps
    end
  end
end
