class AddLikeesToResidents < ActiveRecord::Migration
  def change
    add_column :residents, :likees_count, :integer, :default => 0
    add_column :residents, :likers_count, :integer, :default => 0
  end
end
