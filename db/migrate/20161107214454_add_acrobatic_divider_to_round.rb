class AddAcrobaticDividerToRound < ActiveRecord::Migration
  def change
    add_column :rounds, :acrobatic_divider, :integer, default: 1
  end
end