class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :resident_id
      t.text :text
      t.datetime :created_at
    end
  end
end
