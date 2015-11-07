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
    #delete_ratings=system('rm tmp/files/*.txt')
    #delete_mdb=value=system('rm tmp/files/*.mdb')
    #drop_table=system("RAILS_ENV=#{Rails.env} rake db:drop")
    #migrate_table=system("RAILS_ENV=#{Rails.env} rake db:migrate")
    #flash[:success]=" Export Files gelöscht: #{delete_ratings}
</br> Access Datenbank gelöscht: #{delete_mdb}
</br> JudgeTool Datenbank gelöscht: #{drop_table}
</br> JudgeTool Datenbank erstellt: #{migrate_table}
</br> Passwort zurückgesetzt! user:admin pin:1234
</br> <h1>Prozess oder Server neustarten</h1>"

    redirect_to admin_utilities_index_path

  end
end
