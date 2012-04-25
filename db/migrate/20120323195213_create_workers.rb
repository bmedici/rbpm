class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers, :options => 'engine=MyISAM'  do |t|
      t.string :hostname
      t.integer :pid
      t.timestamps
    end
  end
end
