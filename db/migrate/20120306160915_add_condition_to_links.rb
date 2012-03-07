class AddConditionToLinks < ActiveRecord::Migration
  def change
    add_column :links, :condition, :text, :null => false
  end
end
