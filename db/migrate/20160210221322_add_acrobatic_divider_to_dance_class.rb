class AddAcrobaticDividerToDanceClass < ActiveRecord::Migration
  def change
    add_column :dance_classes, :acrobatic_divider, :integer, default: 1
  end
end
