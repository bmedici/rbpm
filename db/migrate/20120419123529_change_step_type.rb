class ChangeStepType < ActiveRecord::Migration
  def up
    change_column :steps, :type, :string, :null => false, :default => "StepNoop"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
