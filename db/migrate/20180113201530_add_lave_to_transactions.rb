class AddLaveToTransactions < ActiveRecord::Migration
  def change
    rename_column :transactions, :days, :amount
  end
end
