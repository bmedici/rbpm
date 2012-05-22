class CreateSteps < ActiveRecord::Migration
  def change
    create_table :steps, :options => 'engine=MyISAM'  do |t|
      t.string :label
      t.text :description
      t.text :params_old
      t.string :type, :null => false, :default => "StepNoop"
      t.timestamps
    end
  end
end
