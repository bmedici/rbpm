class AddTypeToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :type, :string
  end
end
