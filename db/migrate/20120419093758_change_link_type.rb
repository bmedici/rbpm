class ChangeLinkType < ActiveRecord::Migration
  def up
    change_column :links, :type, :string, :null => false, :default => "Link"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
