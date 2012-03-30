class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.string :hostname
      t.integer :pid
      t.timestamps
    end
  end
end
