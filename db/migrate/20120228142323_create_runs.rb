class CreateRuns < ActiveRecord::Migration
  def change
    create_table :runs do |t|
      t.references :start_step, :as => :step
      t.datetime :completed_at, :null => true
      t.timestamps
    end
  end
end
