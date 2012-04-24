class AddWorkerToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :worker, :text, :null => false, :default => ''
  end
end
