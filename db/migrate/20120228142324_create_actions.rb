class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.references :job
      t.references :step
      t.integer :errno, :default => 0, :null => false
      t.text :errmsg, :default => '', :null => false
      t.datetime :completed_at
      t.timestamps
    end
  end
end
