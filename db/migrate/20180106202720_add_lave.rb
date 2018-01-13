class AddLave < ActiveRecord::Migration
  def change
    add_column :residents, :amount, :decimal
    add_column :residents, :amount_changed_at, :datetime
    remove_column :residents, :expire_at
  end
end
