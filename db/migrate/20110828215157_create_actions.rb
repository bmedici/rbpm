class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.references :run
      t.references :step
      t.text :output
      t.datetime :completed_at
      t.boolean :running => false
      t.timestamps
    end
  end
end
