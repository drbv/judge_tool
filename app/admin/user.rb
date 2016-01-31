ActiveAdmin.register User do

  attributes = %i(login licence wr_id first_name last_name email pin name club_id)

# Filterable attributes on the index screen
  attributes.each do |attr|
    filter attr
  end


# Customize columns displayed on the index screen in the table
  index do
    selectable_column
    attributes.each do |attr|
      column "#{attr}", attr
    end
    actions
  end

  batch_action :update, form: {
                        login: :text,
                        licence: :text,
                        wr_id: :text,
                        first_name: :text,
                        last_name: :text,
                        email: :text,
                        pin: :text,
                        club_id: :text,
                    } do |ids, inputs|
    inputs.each do |key, value|
      inputs.delete key if value.blank?
    end
    User.where(id: ids).update_all(inputs)
    # inputs is a hash of all the form fields you requested
    redirect_to collection_path, notice: [ids, inputs].to_s
  end

# Use the permit_params method to define which attributes may be changed:
  permit_params attributes
end
