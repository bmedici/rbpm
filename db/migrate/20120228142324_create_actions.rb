class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.references :job
      t.references :step
      t.text :output, :default => nil, :null => true
      t.integer :retcode, :default => nil, :null => true
      t.datetime :completed_at
      t.timestamps
    end
  end
end
