class AddFieldsToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :commission, :decimal
    add_column :transactions, :commission_holder_id, :decimal
  end
end
