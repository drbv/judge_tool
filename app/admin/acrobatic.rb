ActiveAdmin.register Acrobatic do

  attributes = %i(dance_round_id acrobatic_type_id position repeated repeating repeated_acrobatic_id)
  config.per_page = 50
# Filterable attributes on the index screen
  attributes.each do |attr|
    filter attr
  end


# Customize columns displayed on the index screen in the table
  #index as: :block do |product|
  #  div for: product do
  #    resource_selection_cell product
  #    h2  auto_link     product.title
  #    div simple_format product.description
  #  end
  #end

  index do
    selectable_column
    attributes.each do |attr|
      column "#{attr}", attr
    end
    actions
  end

# Use the permit_params method to define which attributes may be changed:
  permit_params attributes
end
