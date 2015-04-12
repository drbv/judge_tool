class AddClosedFlagToRounds < ActiveRecord::Migration
  def change
    add_column :rounds, :closed, :boolean, default: false
  end
end
