class RemoveOldFields < ActiveRecord::Migration
  def change
    drop_table :residents
    remove_column :users, :login
  end
end
