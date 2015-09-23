class AddRepeatedToDanceRoundMapping < ActiveRecord::Migration
  def change
    add_column :dance_round_mappings, :repeated, :boolean, default: false
    add_column :dance_round_mappings, :repeating, :boolean, default: false
    add_column :dance_round_mappings, :repeated_mapping_id, :integer
    add_index :dance_round_mappings, :repeated_mapping_id

    add_column :acrobatics, :repeated, :boolean, default: false
    add_column :acrobatics, :repeating, :boolean, default: false
    add_column :acrobatics, :repeated_acrobatic_id, :integer
    add_index :acrobatics, :repeated_acrobatic_id

  end
end
