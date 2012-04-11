class AddJsonToVars < ActiveRecord::Migration
  def change
    add_column :vars, :json, :boolean, :default => false
  end
end
