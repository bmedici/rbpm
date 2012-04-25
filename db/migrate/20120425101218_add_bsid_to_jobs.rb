class AddBsidToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :bsid, :integer, :null => true, :default => nil
  end
end
