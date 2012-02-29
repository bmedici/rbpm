class CreateRuns < ActiveRecord::Migration
  def change
    create_table :runs do |t|
      t.references :step
      t.datetime :completed_at

      t.timestamps
    end
  end
end
