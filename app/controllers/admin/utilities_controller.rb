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

  def download_rating_list
    File.write(Rails.root.join('tmp','rating_list.csv'),'')
    DanceRating.all.each do |rating|
      line = "#{URI.encode_www_form WR_ID: rating.user.id, rt_ID: rating.dance_round.round.position}\n"
      File.open(Rails.root.join('tmp','rating_list.csv'), 'a') do |f|
        f<<(line)
      end
    end
    send_file Rails.root.join('tmp','rating_list.csv')
  end
end
