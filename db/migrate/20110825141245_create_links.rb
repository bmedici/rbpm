class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :label
      t.references :step
      t.references :next
      t.timestamps
    end
  end
end
