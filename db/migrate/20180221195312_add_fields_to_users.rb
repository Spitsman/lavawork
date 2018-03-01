class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :telegram_id, :string
    add_column :users, :telegram_username, :string
    add_column :users, :likees_count, :integer, default: 0
    add_column :users, :likers_count, :integer, default: 0
    add_column :users, :amount, :decimal
    add_column :users, :amount_changed_at, :datetime
    add_column :users, :type, :string, default: 'resident'
  end
end
