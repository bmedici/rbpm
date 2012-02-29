class CreateSteps < ActiveRecord::Migration
  def change
    create_table :steps do |t|
      t.string :label
      t.text :description
      t.text :params
      t.timestamps
    end
  end
end
