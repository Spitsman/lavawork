class RenameColumnInMessages < ActiveRecord::Migration
  def change
    rename_column :messages, :resident_id, :user_id
  end
end
