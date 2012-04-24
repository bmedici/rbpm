class RemoveWorkerIdFromJobs < ActiveRecord::Migration
  def up
    remove_column :jobs, :worker_id
  end

  def down
    add_column :jobs, :worker_id, :integer, :null => true, :default => nil
  end
end
