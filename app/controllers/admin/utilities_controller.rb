class Admin::UtilitiesController < Admin::BaseController
  require 'uri'
  def index
  end

  def db_upload
    uploaded_file = params[:database_file]
    if uploaded_file
      old_file=Dir.glob(Rails.root.join('tmp', '*.mdb')).first
      if old_file.blank? || old_file.split('/').last == uploaded_file.original_filename
        File.open(Rails.root.join('tmp', uploaded_file.original_filename), 'wb') do |file|
          file.write(uploaded_file.read)
        end
      else
        fail()
      end
    end
    redirect_to admin_utilities_index_path
  end

  def judge_tool_reset
    system "RAILS_ENV=#{Rails.env} rake db:drop"
    system "RAILS_ENV=#{Rails.env} rake db:migrate"
    system 'rm tmp/*.txt'
    system 'rm tmp/*.mdb'
    redirect_to root_path
  end
end
