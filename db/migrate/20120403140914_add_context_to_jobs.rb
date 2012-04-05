class AddContextToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :context, :text, :null => false, :default => ''
  end
end