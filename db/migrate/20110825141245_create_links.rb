class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links, :options => 'engine=MyISAM'  do |t|
      t.string :label
      t.references :step
      t.references :next
      t.text :params, :null => false
      t.string :type, :null => false, :default => "Link"
      t.timestamps
    end
  end
end
