class CreateSystems < ActiveRecord::Migration
  def change
    create_table :systems do |t|
      t.string :label
      t.string :monitor_url
      t.text :status_json, :null => false, :default => ""

      t.timestamps
    end
  end
end
