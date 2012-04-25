class DropWorkers < ActiveRecord::Migration
  def up
    drop_table :workers
  end
  def down
    create_table :workers, :options => 'engine=MyISAM'  do |t|
      t.string :hostname
      t.integer :pid
      t.timestamps
    end
  end
end
