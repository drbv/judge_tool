class AddStartedFlagToDanceRounds < ActiveRecord::Migration
  def change
    add_column :dance_rounds, :started, :boolean, default: false
    add_column :rounds, :started, :boolean, default: false
  end
end
