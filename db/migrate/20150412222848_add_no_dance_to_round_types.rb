class AddNoDanceToRoundTypes < ActiveRecord::Migration
  def change
    add_column :round_types, :no_dance, :boolean, default: false
  end
end
