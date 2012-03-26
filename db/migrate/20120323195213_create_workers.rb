class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.string :hostname
      t.integer :pid
      t.timestamps
    end
    add_index :workers, :current_step_id
  end
end
