class CreateParams < ActiveRecord::Migration
  def change
    create_table :params do |t|
      t.references :step
      t.string :name
      t.text :value

      t.timestamps
    end
    add_index :params, :step_id
    add_index :params, :name
  end
end
