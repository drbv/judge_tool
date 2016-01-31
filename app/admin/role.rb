ActiveAdmin.register Role do
  attributes = %i(name resource_id resource_type)
  config.per_page = 50
# Filterable attributes on the index screen
  attributes.each do |attr|
    filter attr
  end

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
